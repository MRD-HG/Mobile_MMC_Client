import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'content_repository.dart';
import 'local_content_repository.dart';
import 'mmc_api_parser.dart';

/// Live data from the public, read-only API of moroccomicrosoftcommunity.com:
/// `GET /events`, `GET /speakers`, `GET /programs`.
class ApiContentRepository implements ContentRepository {
  ApiContentRepository({
    required this.baseUrl,
    http.Client? client,
    AssetBundle? bundle,
    this.timeout = const Duration(seconds: 20),
    DateTime Function()? clock,
  })  : _client = client ?? http.Client(),
        _bundle = bundle ?? rootBundle,
        _clock = clock ?? DateTime.now;

  final String baseUrl;
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
    final parsed = await compute(_parseBodies, bodies);
    return ContentBundle(
      events: parsed.events,
      speakers: parsed.speakers,
      programs: parsed.programs,
      community: await loadCommunityInfo(_bundle),
      origin: ContentOrigin.live,
      updatedAt: _clock(),
    );
  }

  Future<String> _get(String path) async {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
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

ParsedContent _parseBodies(List<String> bodies) => MmcApiParser.parse(
      events: jsonDecode(bodies[0]),
      speakers: jsonDecode(bodies[1]),
      programs: jsonDecode(bodies[2]),
    );
