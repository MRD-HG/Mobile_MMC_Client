import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/community.dart';
import 'api_content_repository.dart' show parseApiBodies;
import 'content_cache.dart';
import 'content_repository.dart';
import 'mmc_api_parser.dart';

/// Loads the community info shipped with the app.
Future<CommunityInfo> loadCommunityInfo(AssetBundle bundle) async {
  final raw = await bundle.loadString(SnapshotContentRepository.communityPath);
  return CommunityInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

/// Offline data: a snapshot of the official API bundled in `assets/data/`.
class SnapshotContentRepository implements ContentRepository {
  SnapshotContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const snapshotPath = 'assets/data/mmc_snapshot.json';
  static const communityPath = 'assets/data/community.json';

  @override
  Future<ContentBundle> load() async {
    final raw = await _bundle.loadString(snapshotPath, cache: false);
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid snapshot file');
    }
    final parsed = MmcApiParser.parse(
      events: json['events'],
      speakers: json['speakers'],
      programs: json['programs'],
    );
    final meta = json['_meta'];
    return ContentBundle(
      events: parsed.events,
      speakers: parsed.speakers,
      programs: parsed.programs,
      community: await loadCommunityInfo(_bundle),
      origin: ContentOrigin.snapshot,
      updatedAt: meta is Map ? DateTime.tryParse('${meta['exportedAt']}') : null,
    );
  }
}

/// The last successful API fetch, persisted on device (MMC-004).
class CachedContentRepository implements ContentRepository {
  CachedContentRepository(this._cache, {AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  final ContentCache _cache;
  final AssetBundle _bundle;

  @override
  Future<ContentBundle> load() async {
    final cached = await _cache.load();
    if (cached == null) throw StateError('No cached content');
    final parsed = await compute(parseApiBodies,
        [cached.eventsBody, cached.speakersBody, cached.programsBody]);
    if (parsed.events.isEmpty) throw StateError('Cached content unusable');
    return ContentBundle(
      events: parsed.events,
      speakers: parsed.speakers,
      programs: parsed.programs,
      community: await loadCommunityInfo(_bundle),
      origin: ContentOrigin.cached,
      updatedAt: cached.fetchedAt,
    );
  }
}

/// Tries each repository in order and returns the first that loads
/// (cache first, bundled snapshot as the floor).
class ChainContentRepository implements ContentRepository {
  ChainContentRepository(this.repositories)
      : assert(repositories.isNotEmpty, 'Need at least one repository');

  final List<ContentRepository> repositories;

  @override
  Future<ContentBundle> load() async {
    Object? lastError;
    for (final repo in repositories) {
      try {
        return await repo.load();
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError!;
  }
}
