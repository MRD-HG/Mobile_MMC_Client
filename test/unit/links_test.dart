import 'package:client_mobile/core/utils/links.dart';
import 'package:client_mobile/data/models/event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Links.isSafe (MMC-015)', () {
    test('allows https, http and mailto', () {
      expect(Links.isSafe('https://example.org/x'), isTrue);
      expect(Links.isSafe('http://example.org'), isTrue);
      expect(Links.isSafe('mailto:someone@example.org'), isTrue);
    });

    test('rejects everything else', () {
      expect(Links.isSafe('javascript:alert(1)'), isFalse);
      expect(Links.isSafe('file:///etc/passwd'), isFalse);
      expect(Links.isSafe('intent://scan/#Intent;end'), isFalse);
      expect(Links.isSafe('tel:+212600000000'), isFalse);
      expect(Links.isSafe('#'), isFalse);
      expect(Links.isSafe('https://'), isFalse);
      expect(Links.isSafe(''), isFalse);
    });
  });

  group('Links.calendarUri', () {
    test('timed event exports timestamps', () {
      final e = MmcEvent.fromApi(const {
        'id': 'x',
        'title': 'Timed',
        'date': '2026-11-26',
        'time': '09:00 AM - 05:00 PM',
      });
      final dates = Links.calendarUri(e).queryParameters['dates']!;
      expect(dates, contains('T'));
      expect(dates.split('/'), hasLength(2));
    });

    test('event without a published time exports an all-day entry (MMC-007)', () {
      final e = MmcEvent.fromApi(const {
        'id': 'x',
        'title': 'All day',
        'date': '2026-11-26',
      });
      expect(Links.calendarUri(e).queryParameters['dates'], '20261126/20261127');
    });
  });
}
