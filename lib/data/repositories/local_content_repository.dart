import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/community.dart';
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
