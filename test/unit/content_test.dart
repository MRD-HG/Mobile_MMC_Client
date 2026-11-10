import 'dart:convert';
import 'dart:typed_data';

import 'package:client_mobile/app/controllers.dart';
import 'package:client_mobile/core/storage/key_value_store.dart';
import 'package:client_mobile/data/repositories/api_content_repository.dart';
import 'package:client_mobile/data/repositories/content_repository.dart';
import 'package:client_mobile/features/events/events_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/fixtures.dart';

class _StringBundle extends CachingAssetBundle {
  _StringBundle(this.files);
  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final value = files[key];
    if (value == null) throw FlutterError('missing $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }
}

void main() {
  group('ContentBundle', () {
    final bundle = testBundle();

    test('sorted newest first, upcoming soonest first', () {
      expect(bundle.events.first.id, 'ev-oujda');
      expect(bundle.upcoming(testNow).map((e) => e.id), ['ev-oujda']);
      expect(bundle.past(testNow).map((e) => e.id), ['ev-webinar', 'ev-tanger']);
    });

    test('relations', () {
      expect(bundle.eventsForSpeaker('sp-1').length, 2);
      expect(bundle.speakersFor(bundle.eventById('ev-tanger')!).length, 2);
      expect(bundle.eventById('gaib-tanger')?.id, 'ev-tanger', reason: 'lookup by slug');
      expect(bundle.activePrograms.length, 2);
      expect(bundle.cities, {'Oujda', 'Tanger'});
    });
  });

  group('filterEvents', () {
    final events = testBundle().events;

    test('by time', () {
      expect(filterEvents(events, now: testNow, time: EventTimeFilter.upcoming).length, 1);
      expect(filterEvents(events, now: testNow, time: EventTimeFilter.past).length, 2);
    });

    test('by query and topic', () {
      expect(filterEvents(events, now: testNow, query: 'tanger').single.id, 'ev-tanger');
      expect(filterEvents(events, now: testNow, topic: 'DevOps').single.id, 'ev-webinar');
      expect(filterEvents(events, now: testNow, query: 'zzz'), isEmpty);
    });
  });

  group('ContentController', () {
    test('shows offline data, then live data', () async {
      final live = ContentBundle(
        events: testEvents.take(1).toList(),
        speakers: testSpeakers,
        programs: testPrograms,
        community: testCommunity,
        origin: ContentOrigin.live,
      );
      final c = ContentController(
        offline: FakeRepository(testBundle()),
        online: FakeRepository(live),
      );
      await c.load();
      expect(c.status, LoadStatus.ready);
      await c.refresh(); // completes the background refresh deterministically
      expect(c.data!.origin, ContentOrigin.live);
      expect(c.refreshFailed, isFalse);
    });

    test('keeps the snapshot when the network fails', () async {
      final c = ContentController(
        offline: FakeRepository(testBundle()),
        online: FakeRepository(testBundle(), fail: true),
      );
      await c.load();
      await c.refresh();
      expect(c.data, isNotNull);
      expect(c.data!.origin, ContentOrigin.snapshot);
      expect(c.refreshFailed, isTrue);
    });

    test('error state then retry', () async {
      final repo = FakeRepository(testBundle(), fail: true);
      final c = ContentController(offline: repo);
      await c.load();
      expect(c.status, LoadStatus.error);
      repo.fail = false;
      await c.retry();
      expect(c.status, LoadStatus.ready);
    });
  });

  group('Preferences', () {
    test('bookmarks persist', () async {
      final store = MemoryStore();
      await BookmarksController(store).toggle('ev-oujda');
      expect(BookmarksController(store).isSaved('ev-oujda'), isTrue);
    });

    test('settings persist', () async {
      final store = MemoryStore();
      final s = SettingsController(store);
      await s.setThemeMode(ThemeMode.dark);
      await s.setLocaleCode('fr');
      await s.toggleTopic('AI');
      final reloaded = SettingsController(store);
      expect(reloaded.themeMode, ThemeMode.dark);
      expect(reloaded.locale, const Locale('fr'));
      expect(reloaded.favoriteTopics, {'AI'});
    });
  });

  group('ApiContentRepository', () {
    final community = jsonEncode({'name': 'MMC', 'about': 'x'});
    final assets = _StringBundle({'assets/data/community.json': community});

    test('maps the three endpoints', () async {
      final client = MockClient((req) async {
        switch (req.url.path) {
          case '/api/events':
            return http.Response(
                jsonEncode([
                  {'id': 'e1', 'title': 'Tech Day', 'date': '2026-11-26', 'time': '9:30', 'status': 'published'},
                  {'id': 'e2', 'title': 'Draft', 'date': '2026-12-01', 'status': 'draft'},
                ]),
                200,
                headers: {'content-type': 'application/json; charset=utf-8'});
          case '/api/speakers':
            return http.Response(jsonEncode([{'id': 's1', 'name': 'A'}]), 200);
          case '/api/programs':
            return http.Response(jsonEncode([{'id': 'p1', 'name': 'MMC'}]), 200);
        }
        return http.Response('not found', 404);
      });
      final repo = ApiContentRepository(
        baseUrl: 'https://example.org/api/',
        client: client,
        bundle: assets,
      );
      final bundle = await repo.load();
      expect(bundle.origin, ContentOrigin.live);
      expect(bundle.events.map((e) => e.id), ['e1'], reason: 'drafts are hidden');
      expect(bundle.events.single.start, DateTime(2026, 11, 26, 9, 30));
      expect(bundle.speakers.single.name, 'A');
      expect(bundle.programs.single.title, 'MMC');
    });

    test('throws on HTTP errors', () async {
      final repo = ApiContentRepository(
        baseUrl: 'https://example.org/api',
        client: MockClient((_) async => http.Response('boom', 500)),
        bundle: assets,
      );
      await expectLater(repo.load(), throwsA(isA<http.ClientException>()));
    });
  });
}
