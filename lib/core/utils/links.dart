import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/event.dart';
import '../l10n/strings.dart';

class Links {
  const Links._();

  /// Only these schemes may leave the app (MMC-015). Content is remote
  /// data, so anything else (javascript:, file:, intent:, tel:...) is
  /// refused rather than handed to the OS.
  static const allowedSchemes = {'https', 'http', 'mailto'};

  static bool isSafe(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return false;
    if (!allowedSchemes.contains(uri.scheme)) return false;
    if (uri.scheme != 'mailto' && uri.host.isEmpty) return false;
    return true;
  }

  /// Opens [url] in the external browser/app; shows a SnackBar on failure
  /// or on an unsupported scheme.
  static Future<void> open(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final errorText = context.s.linkError;
    var ok = false;
    if (isSafe(url)) {
      try {
        ok = await launchUrl(Uri.parse(url.trim()),
            mode: LaunchMode.externalApplication);
      } catch (_) {
        ok = false;
      }
    }
    if (!ok) {
      messenger?.showSnackBar(SnackBar(content: Text(errorText)));
    }
  }

  /// Google Calendar "add event" link — works on any device without
  /// calendar permissions or native plugins. Events without a published
  /// time are exported as all-day entries instead of a fabricated 09:00.
  static Uri calendarUri(MmcEvent e) {
    String stamp(DateTime d) {
      final u = d.toUtc();
      String two(int v) => v.toString().padLeft(2, '0');
      return '${u.year}${two(u.month)}${two(u.day)}T${two(u.hour)}${two(u.minute)}00Z';
    }

    String day(DateTime d) {
      String two(int v) => v.toString().padLeft(2, '0');
      return '${d.year}${two(d.month)}${two(d.day)}';
    }

    final String dates;
    if (e.timeKnown) {
      final end = e.end ?? e.start.add(const Duration(hours: 2));
      dates = '${stamp(e.start)}/${stamp(end.isAfter(e.start) ? end : e.start.add(const Duration(hours: 2)))}';
    } else {
      // All-day format: end date is exclusive.
      final endDay = e.effectiveEnd.add(const Duration(days: 1));
      dates = '${day(e.start)}/${day(endDay)}';
    }

    return Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': e.title,
      'dates': dates,
      'details': e.description,
      if (e.location.isNotEmpty) 'location': e.location,
    });
  }
}
