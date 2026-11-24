import 'package:client_mobile/app/app.dart';
import 'package:client_mobile/app/controllers.dart';
import 'package:client_mobile/app/router.dart';
import 'package:client_mobile/core/storage/key_value_store.dart';
import 'package:client_mobile/data/models/community.dart';
import 'package:client_mobile/data/models/event.dart';
import 'package:client_mobile/data/models/program.dart';
import 'package:client_mobile/data/models/speaker.dart';
import 'package:client_mobile/data/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixed "now" used by all tests: 10 Nov 2026, 12:00.
final testNow = DateTime(2026, 11, 10, 12);

const testCommunity = CommunityInfo(
  name: 'Morocco Microsoft Community',
  shortName: 'MMC',
  about: {'en': 'About MMC', 'fr': 'À propos de MMC'},
  links: [CommunityLink(type: 'website', label: 'Website', url: 'https://example.org')],
);

final testSpeakers = [
  Speaker.fromApi(const {
    'id': 'sp-1',
    'name': 'Hassan Fadili',
    'slug': 'hassan-fadili',
    'title': 'Cloud, DevOps & GitHub Consultant - Microsoft MVP',
    'bio': 'Sharing is my passion.',
    'social': {'linkedin': 'https://www.linkedin.com/in/someone/', 'twitter': 'https://x.com/'},
  }),
  Speaker.fromApi(const {
    'id': 'sp-2',
    'name': 'Said WAHID',
    'slug': 'said-wahid',
    'title': 'Microsoft MVP & MCT | Microsoft Engineer',
  }),
];

final testPrograms = [
  Program.fromApi(const {'id': 'p-ai', 'name': 'The Global AI BootCamp', 'description': 'AI'}),
  Program.fromApi(const {'id': 'p-day', 'name': 'Microsoft Tech Day', 'description': 'Days'}),
];

final testEvents = [
  MmcEvent.fromApi(const {
    'id': 'ev-oujda',
    'slug': 'microsoft-tech-day-oujda',
    'title': 'Microsoft Tech Day – Oujda',
    'description': '<p>Azure, Copilot and AI day.</p>',
    'date': '2026-11-26',
    'time': '09:00 AM - 05:00 PM',
    'location': 'EHEIM',
    'city': 'Oujda',
    'isOnline': false,
    'registrationMode': 'internal',
    'programId': 'p-day',
    'speakers': [
      {'id': 'sp-1', 'sessionTitle': 'Session Title: GitHub Copilot', 'sessionDuration': 45},
    ],
    'media': [],
  }),
  MmcEvent.fromApi(const {
    'id': 'ev-tanger',
    'slug': 'gaib-tanger',
    'title': 'Global AI Bootcamp – Tanger',
    'description': 'AI bootcamp',
    'date': '2024-04-26',
    'time': '9:00am - 4:30pm',
    'location': 'Technopark',
    'city': 'Tanger',
    'programId': 'p-ai',
    'speakers': [
      {'id': 'sp-1'},
      {'id': 'sp-2'},
    ],
  }),
  MmcEvent.fromApi(const {
    'id': 'ev-webinar',
    'title': 'Azure DevOps webinar',
    'date': '2025-06-10',
    'time': '20:00 - 21:00',
    'city': 'Online',
    'isOnline': true,
    'registrationMode': 'external',
    'externalRegistrationUrl': 'https://luma.com/abc',
  }),
];

ContentBundle testBundle() => ContentBundle(
      events: testEvents,
      speakers: testSpeakers,
      programs: testPrograms,
      community: testCommunity,
    );

class FakeRepository implements ContentRepository {
  FakeRepository(this.bundle, {this.fail = false});

  final ContentBundle bundle;
  bool fail;
  int calls = 0;

  @override
  Future<ContentBundle> load() async {
    calls++;
    if (fail) throw Exception('offline');
    return bundle;
  }
}

/// Pumps the full app on a given route with fake data and no network.
Future<void> pumpApp(
  WidgetTester tester, {
  String route = AppRouter.home,
  ContentRepository? repository,
  KeyValueStore? store,
}) async {
  final kv = store ?? MemoryStore();
  await tester.pumpWidget(MmcApp(
    content: ContentController(offline: repository ?? FakeRepository(testBundle())),
    bookmarks: BookmarksController(kv),
    settings: SettingsController(kv)..setLocaleCode('en'),
    clock: () => testNow,
    initialRoute: route,
  ));
}

