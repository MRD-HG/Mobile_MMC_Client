import 'package:client_mobile/data/models/event.dart';
import 'package:client_mobile/data/models/speaker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('parseTimeRange (formats found in the real API)', () {
    final cases = <String, ((int, int)?, (int, int)?)>{
      '9:30': ((9, 30), null),
      '09:00 - 17:00': ((9, 0), (17, 0)),
      '09:00 AM - 05:00 PM': ((9, 0), (17, 0)),
      '9:00am - 4:00pm': ((9, 0), (16, 0)),
      '10:00am - 4:00pm (UTC +1)': ((10, 0), (16, 0)),
      '08:00 PM - 09:00 PM': ((20, 0), (21, 0)),
      '10h00 - 13h30': ((10, 0), (13, 30)),
      '19h': ((19, 0), null),
      '14:00 PM ': ((14, 0), null),
      '': (null, null),
    };
    cases.forEach((input, expected) {
      test('"$input"', () => expect(parseTimeRange(input), expected));
    });
  });

  group('MmcEvent.fromApi', () {
    final oujda = testEvents.firstWhere((e) => e.id == 'ev-oujda');
    final webinar = testEvents.firstWhere((e) => e.id == 'ev-webinar');

    test('combines date and time', () {
      expect(oujda.start, DateTime(2026, 11, 26, 9));
      expect(oujda.end, DateTime(2026, 11, 26, 17));
    });

    test('strips HTML from descriptions', () {
      expect(oujda.description, 'Azure, Copilot and AI day.');
    });

    test('internal registration points to the official event page', () {
      expect(oujda.registrationUrl,
          'https://moroccomicrosoftcommunity.com/events/microsoft-tech-day-oujda');
    });

    test('external registration uses the organiser link', () {
      expect(webinar.registrationUrl, 'https://luma.com/abc');
      expect(webinar.isOnline, isTrue);
      expect(webinar.city, isNull);
    });

    test('detects topics only from words present in the text', () {
      expect(oujda.topics, containsAll(['Azure', 'Copilot', 'AI']));
      expect(oujda.topics, isNot(contains('.NET')));
    });

    test('cleans "Session Title:" prefixes', () {
      expect(oujda.sessions.single.cleanTitle, 'GitHub Copilot');
      expect(oujda.sessions.single.durationMinutes, 45);
    });

    test('upcoming / past relative to a clock', () {
      expect(oujda.isUpcoming(testNow), isTrue);
      expect(webinar.isUpcoming(testNow), isFalse);
    });

    test('search is case and accent insensitive', () {
      final e = MmcEvent.fromApi(const {
        'id': 'x',
        'title': 'Journée Fès',
        'date': '2025-01-01',
        'city': 'Fès',
      });
      expect(e.matches('fes'), isTrue);
      expect(e.matches('JOURNEE'), isTrue);
      expect(e.matches('rabat'), isFalse);
    });

    test('malformed time falls back to 09:00', () {
      final e = MmcEvent.fromApi(const {'id': 'x', 'title': 't', 'date': '2025-03-01', 'time': 'TBA'});
      expect(e.start, DateTime(2025, 3, 1, 9));
    });
  });

  group('Speaker', () {
    test('drops placeholder social links and classifies by host', () {
      final s = Speaker.fromApi(const {
        'id': '1',
        'name': 'Test',
        'social': {
          'twitter': 'https://www.instagram.com/someone',
          'github': 'https://x.com/',
          'linkedin': '#',
        },
      });
      expect(s.links.map((l) => l.kind), [SocialKind.instagram]);
    });

    test('normalises all-caps names and splits roles', () {
      final said = testSpeakers[1];
      expect(said.displayName, 'Said Wahid');
      expect(said.initials, 'SW');
      expect(said.roles, ['Microsoft MVP & MCT', 'Microsoft Engineer']);
      expect(said.isMvp, isTrue);
    });

    test('bundled avatar for the founding team', () {
      expect(testSpeakers[0].localAvatar, 'assets/images/speakers/hassan_fadili.jpg');
    });

    test('relative avatar paths are resolved against the website', () {
      final s = Speaker.fromApi(const {'id': '1', 'name': 'A', 'avatar': '/speakers/a.jpg'});
      expect(s.avatarUrl, 'https://moroccomicrosoftcommunity.com/speakers/a.jpg');
    });
  });
}
