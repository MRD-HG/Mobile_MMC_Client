import 'dart:convert';

import '../../core/storage/blob_store.dart';

/// Persists the raw bodies of the last successful API fetch, so a later
/// cold start without network shows the latest data instead of the
/// (older) bundled snapshot.
class ContentCache {
  ContentCache(this._store);

  static const _key = 'mmc_content_cache_v1.json';

  final BlobStore _store;

  Future<void> save({
    required DateTime fetchedAt,
    required String eventsBody,
    required String speakersBody,
    required String programsBody,
  }) =>
      _store.write(
        _key,
        jsonEncode({
          'fetchedAt': fetchedAt.toIso8601String(),
          'events': eventsBody,
          'speakers': speakersBody,
          'programs': programsBody,
        }),
      );

  /// Returns null when there is no cache or it is unreadable.
  Future<CachedContent?> load() async {
    final raw = await _store.read(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      final events = json['events'];
      final speakers = json['speakers'];
      final programs = json['programs'];
      if (events is! String || speakers is! String || programs is! String) {
        return null;
      }
      return CachedContent(
        fetchedAt: DateTime.tryParse('${json['fetchedAt']}'),
        eventsBody: events,
        speakersBody: speakers,
        programsBody: programs,
      );
    } catch (_) {
      await _store.delete(_key); // corrupted cache: discard
      return null;
    }
  }
}

class CachedContent {
  const CachedContent({
    required this.fetchedAt,
    required this.eventsBody,
    required this.speakersBody,
    required this.programsBody,
  });

  final DateTime? fetchedAt;
  final String eventsBody;
  final String speakersBody;
  final String programsBody;
}
