import '../models/community.dart';
import '../models/event.dart';
import '../models/program.dart';
import '../models/speaker.dart';

enum ContentOrigin { live, snapshot }

/// Everything the app displays, loaded in one go.
class ContentBundle {
  ContentBundle({
    required List<MmcEvent> events,
    required this.speakers,
    required this.programs,
    required this.community,
    this.origin = ContentOrigin.snapshot,
    this.updatedAt,
  }) : events = List.unmodifiable(
            [...events]..sort((a, b) => b.start.compareTo(a.start)));

  /// Sorted newest first.
  final List<MmcEvent> events;
  final List<Speaker> speakers;
  final List<Program> programs;
  final CommunityInfo community;
  final ContentOrigin origin;

  /// When the data was fetched (live) or exported (snapshot).
  final DateTime? updatedAt;

  ContentBundle copyWith({CommunityInfo? community}) => ContentBundle(
        events: events,
        speakers: speakers,
        programs: programs,
        community: community ?? this.community,
        origin: origin,
        updatedAt: updatedAt,
      );

  MmcEvent? eventById(String id) => _first(events, (e) => e.id == id || e.slug == id);
  Speaker? speakerById(String id) => _first(speakers, (s) => s.id == id || s.slug == id);
  Program? programById(String? id) => id == null ? null : _first(programs, (p) => p.id == id);

  List<Speaker> speakersFor(MmcEvent event) =>
      event.speakerIds.map(speakerById).whereType<Speaker>().toList();

  List<MmcEvent> eventsForSpeaker(String speakerId) =>
      events.where((e) => e.speakerIds.contains(speakerId)).toList();

  List<MmcEvent> eventsForProgram(String programId) =>
      events.where((e) => e.programId == programId).toList();

  /// Programs that have at least one event, most active first.
  List<Program> get activePrograms {
    final counts = <String, int>{};
    for (final e in events) {
      final id = e.programId;
      if (id != null) counts[id] = (counts[id] ?? 0) + 1;
    }
    return programs.where((p) => (counts[p.id] ?? 0) > 0).toList()
      ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
  }

  /// Soonest first.
  List<MmcEvent> upcoming(DateTime now) =>
      events.where((e) => e.isUpcoming(now)).toList()
        ..sort((a, b) => a.start.compareTo(b.start));

  /// Most recent first.
  List<MmcEvent> past(DateTime now) => events.where((e) => !e.isUpcoming(now)).toList();

  List<String> get allTopics {
    final counts = <String, int>{};
    for (final e in events) {
      for (final t in e.topics) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    return counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  }

  /// Distinct physical cities (online events excluded).
  Set<String> get cities => events
      .where((e) => !e.isOnline)
      .map((e) => e.city)
      .whereType<String>()
      .toSet();

  static T? _first<T>(List<T> list, bool Function(T) test) {
    for (final item in list) {
      if (test(item)) return item;
    }
    return null;
  }
}

/// Data-source abstraction. Screens never talk to HTTP or assets directly.
abstract class ContentRepository {
  Future<ContentBundle> load();
}
