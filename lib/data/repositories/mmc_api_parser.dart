import '../models/event.dart';
import '../models/program.dart';
import '../models/speaker.dart';

/// Parsed API payloads with parsing diagnostics.
class ParsedContent {
  const ParsedContent(this.events, this.speakers, this.programs,
      {this.skippedRecords = 0});

  final List<MmcEvent> events;
  final List<Speaker> speakers;
  final List<Program> programs;

  /// Records rejected because they were malformed (no date, no title...).
  final int skippedRecords;
}

/// Pure mapping from the moroccomicrosoftcommunity.com API JSON shape.
/// Shared by the live repository, the cache and the bundled snapshot.
class MmcApiParser {
  const MmcApiParser._();

  static ParsedContent parse({
    required Object? events,
    required Object? speakers,
    required Object? programs,
  }) {
    var skipped = 0;
    List<T> mapAll<T>(Object? list, T Function(Map<String, dynamic>) f,
        {bool Function(Map<String, dynamic>)? where}) {
      final out = <T>[];
      for (final item in _maps(list)) {
        if (where != null && !where(item)) continue;
        try {
          out.add(f(item));
        } catch (_) {
          skipped++; // One malformed record must not break the whole list.
        }
      }
      return out;
    }

    final parsedEvents = mapAll(events, MmcEvent.fromApi,
        // Hide drafts if the API ever exposes them.
        where: (e) => e['status'] == null || e['status'] == 'published');
    final parsedSpeakers = mapAll(speakers, Speaker.fromApi);
    final parsedPrograms = mapAll(programs, Program.fromApi);

    // Duplicate ids keep the first occurrence.
    final seen = <String>{};
    final dedupedEvents =
        parsedEvents.where((e) => seen.add(e.id)).toList(growable: false);
    skipped += parsedEvents.length - dedupedEvents.length;

    return ParsedContent(dedupedEvents, parsedSpeakers, parsedPrograms,
        skippedRecords: skipped);
  }

  static List<Map<String, dynamic>> _maps(Object? value) {
    if (value is! List) throw const FormatException('Expected a JSON array');
    return value.whereType<Map<String, dynamic>>().toList();
  }
}
