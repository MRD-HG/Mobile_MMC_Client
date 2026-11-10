import '../models/event.dart';
import '../models/program.dart';
import '../models/speaker.dart';

/// Parsed API payloads (events, speakers, programs).
class ParsedContent {
  const ParsedContent(this.events, this.speakers, this.programs);

  final List<MmcEvent> events;
  final List<Speaker> speakers;
  final List<Program> programs;
}

/// Pure mapping from the moroccomicrosoftcommunity.com API JSON shape.
/// Shared by the live repository and the bundled snapshot.
class MmcApiParser {
  const MmcApiParser._();

  static ParsedContent parse({
    required Object? events,
    required Object? speakers,
    required Object? programs,
  }) {
    final parsedEvents = _maps(events)
        // Hide drafts if the API ever exposes them.
        .where((e) => e['status'] == null || e['status'] == 'published')
        .map(_safe(MmcEvent.fromApi))
        .whereType<MmcEvent>()
        .toList();
    final parsedSpeakers =
        _maps(speakers).map(_safe(Speaker.fromApi)).whereType<Speaker>().toList();
    final parsedPrograms =
        _maps(programs).map(_safe(Program.fromApi)).whereType<Program>().toList();
    return ParsedContent(parsedEvents, parsedSpeakers, parsedPrograms);
  }

  static List<Map<String, dynamic>> _maps(Object? value) {
    if (value is! List) throw const FormatException('Expected a JSON array');
    return value.whereType<Map<String, dynamic>>().toList();
  }

  /// One malformed record must not break the whole list.
  static T? Function(Map<String, dynamic>) _safe<T>(T Function(Map<String, dynamic>) f) =>
      (json) {
        try {
          return f(json);
        } catch (_) {
          return null;
        }
      };
}
