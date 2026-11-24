import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/controllers.dart';
import 'core/config/app_config.dart';
import 'core/storage/blob_store.dart';
import 'core/storage/key_value_store.dart';
import 'data/repositories/api_content_repository.dart';
import 'data/repositories/content_cache.dart';
import 'data/repositories/local_content_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final store = await SharedPrefsStore.create();
  final cache = ContentCache(FileBlobStore());

  runApp(MmcApp(
    // Offline-first lifecycle:
    //   1. last successful API fetch (persisted cache), else bundled snapshot
    //   2. background refresh from the live MMC API, validated before it
    //      replaces anything, and persisted for the next start.
    content: ContentController(
      offline: ChainContentRepository([
        CachedContentRepository(cache),
        SnapshotContentRepository(),
      ]),
      online: AppConfig.offlineOnly
          ? null
          : ApiContentRepository(baseUrl: AppConfig.apiBaseUrl, cache: cache),
    ),
    bookmarks: BookmarksController(store),
    settings: SettingsController(store),
  ));
}
