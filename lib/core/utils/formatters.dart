import 'package:intl/intl.dart';

import '../../data/models/event.dart';

class Formatters {
  const Formatters._();

  /// e.g. "Sat 14 Dec 2024" / "sam. 14 déc. 2024"
  static String longDate(DateTime d, String locale) =>
      DateFormat('EEE d MMM y', locale).format(d);

  static String time(DateTime d, String locale) => DateFormat.Hm(locale).format(d);

  /// "09:00" or "09:30 – 16:30".
  static String timeRange(MmcEvent e, String locale) {
    final start = time(e.start, locale);
    final end = e.end;
    if (end == null || !end.isAfter(e.start)) return start;
    return '$start – ${time(end, locale)}';
  }

  /// Compact date badge parts: day ("14"), month ("DEC"), year ("2024").
  static (String, String, String) dateBadge(DateTime d, String locale) => (
        DateFormat('d', locale).format(d),
        DateFormat('MMM', locale).format(d).toUpperCase().replaceAll('.', ''),
        DateFormat('y', locale).format(d),
      );
}
