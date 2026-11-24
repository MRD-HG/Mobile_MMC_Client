import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'content_cache.dart';
import 'content_repository.dart';
import 'local_content_repository.dart';
import 'mmc_api_parser.dart';

/// Thrown when the API answers 200 but the payload looks wrong (empty
/// catalog, all records malformed). Treated like a network failure, so the
/// cached/bundled data is kept instead of being wiped out.
class SuspiciousDataException implements Exception {
  const SuspiciousDataException(this.message);
  final String message;

  @override
  String toString() => 'SuspiciousDataException: $message';
}

/// Live data from the public, read-only API of moroccomicrosoftcommunity.com:
/// `GET /events`, `GET /speakers`, `GET /programs`.
///
/// A successful, validated fetch is persisted to [cache] so the next cold
/// start without network uses it instead of the older bundled snapshot.
class ApiContentRepository implements ContentRepository {
  ApiContentRepository({
    required this.baseUrl,
    this.cache,
    http.Client? client,
    AssetBundle? bundle,
    this.timeout = const Duration(seconds: 20),
    DateTime Function()? clock,
  })  : _client = client ?? http.Client(),
        _bundle = bundle ?? rootBundle,
        _clock = clock ?? DateTime.now;

  final String baseUrl;
  final ContentCache? cache;
  final Duration timeout;
  final http.Client _client;
  final AssetBundle _bundle;
  final DateTime Function() _clock;

  @override
  Future<ContentBundle> load() async {
    final bodies = await Future.wait([
      _get('events'),
      _get('speakers'),
      _get('programs'),
    ]);
    // The events payload is large (~1.7 MB): decode off the UI thread.
    final parsed = await compute(parseApiBodies, bodies);

    // The real MMC catalog has >100 events and several speakers. An empty
    // or heavily broken answer is a data-source failure, not "no events":
    // keep the current data rather than overwrite it (MMC-003).
    if (parsed.events.isEmpty || parsed.speakers.isEmpty) {
      throw const SuspiciousDataException('API returned an empty catalog');
    }
    if (parsed.skippedRecords > parsed.events.length) {
      throw SuspiciousDataException(
          '${parsed.skippedRecords} malformed records — schema change?');
    }

    final fetchedAt = _clock();
    await cache?.save(
      fetchedAt: fetchedAt,
      eventsBody: bodies[0],
      speakersBody: bodies[1],
      programsBody: bodies[2],
    );

    return ContentBundle(
      events: parsed.events,
      speakers: parsed.speakers,
      programs: parsed.programs,
      community: await loadCommunityInfo(_bundle),
      origin: ContentOrigin.live,
      updatedAt: fetchedAt,
    );
  }

  Future<String> _get(String path) async {
    final base =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final uri = Uri.parse('$base/$path');
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', uri);
    }
    return utf8.decode(response.bodyBytes);
  }
}

/// Top-level so it can run in an isolate via `compute`.
ParsedContent parseApiBodies(List<String> bodies) => MmcApiParser.parse(
      events: jsonDecode(bodies[0]),
      speakers: jsonDecode(bodies[1]),
      programs: jsonDecode(bodies[2]),
    );
