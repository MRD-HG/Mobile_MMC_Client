import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/event.dart';
import '../l10n/strings.dart';

class Links {
  const Links._();

  /// Opens [url] in the external browser/app; shows a SnackBar on failure.
  static Future<void> open(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final errorText = context.s.linkError;
    final uri = Uri.tryParse(url);
    var ok = false;
    if (uri != null) {
      try {
        ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        ok = false;
      }
    }
    if (!ok) {
      messenger?.showSnackBar(SnackBar(content: Text(errorText)));
    }
  }

  /// Google Calendar "add event" link — works on any device without
  /// calendar permissions or native plugins.
  static Uri calendarUri(MmcEvent e) {
    String fmt(DateTime d) {
      final u = d.toUtc();
      String two(int v) => v.toString().padLeft(2, '0');
      return '${u.year}${two(u.month)}${two(u.day)}T${two(u.hour)}${two(u.minute)}00Z';
    }

    return Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': e.title,
      'dates': '${fmt(e.start)}/${fmt(e.effectiveEnd)}',
      'details': e.description,
      if (e.location.isNotEmpty) 'location': e.location,
    });
  }
}
