import 'dart:convert';
import 'dart:io';

import 'package:client_mobile/data/models/community.dart';
import 'package:client_mobile/data/repositories/mmc_api_parser.dart';
import 'package:flutter_test/flutter_test.dart';

/// Validates the bundled offline data against the parser.
void main() {
  final snapshot =
      jsonDecode(File('assets/data/mmc_snapshot.json').readAsStringSync()) as Map<String, dynamic>;
  final parsed = MmcApiParser.parse(
    events: snapshot['events'],
    speakers: snapshot['speakers'],
    programs: snapshot['programs'],
  );

  test('all records parse', () {
    expect(parsed.events.length, (snapshot['events'] as List).length);
    expect(parsed.speakers.length, (snapshot['speakers'] as List).length);
    expect(parsed.programs.length, (snapshot['programs'] as List).length);
    expect(parsed.events, isNotEmpty);
  });

  test('event ids are unique and titles non-empty', () {
    final ids = parsed.events.map((e) => e.id).toSet();
    expect(ids.length, parsed.events.length);
    expect(parsed.events.where((e) => e.title.isEmpty), isEmpty);
  });

  test('every session speaker exists', () {
    final speakerIds = parsed.speakers.map((s) => s.id).toSet();
    for (final e in parsed.events) {
      for (final id in e.speakerIds) {
        expect(speakerIds, contains(id), reason: 'event ${e.id}');
      }
    }
  });

  test('every programId refers to a known program', () {
    final programIds = parsed.programs.map((p) => p.id).toSet();
    for (final e in parsed.events) {
      if (e.programId != null) expect(programIds, contains(e.programId), reason: e.title);
    }
  });

  test('times are parsed (no event stuck at midnight unless published so)', () {
    final midnight = parsed.events
        .where((e) => e.start.hour == 0 && !(e.timeLabel ?? '').startsWith('00'));
    expect(midnight, isEmpty);
  });

  test('community.json is valid and referenced assets exist', () {
    final info = CommunityInfo.fromJson(
        jsonDecode(File('assets/data/community.json').readAsStringSync())
            as Map<String, dynamic>);
    expect(info.links, isNotEmpty);
    for (final path in info.gallery) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });

  test('bundled speaker photos exist', () {
    for (final s in parsed.speakers) {
      final local = s.localAvatar;
      if (local != null) expect(File(local).existsSync(), isTrue, reason: local);
    }
  });
}
