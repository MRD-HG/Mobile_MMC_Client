import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/controllers.dart';
import 'core/config/app_config.dart';
import 'core/storage/key_value_store.dart';
import 'data/repositories/api_content_repository.dart';
import 'data/repositories/local_content_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final store = await SharedPrefsStore.create();

  runApp(MmcApp(
    // Offline-first: the bundled snapshot shows instantly, then the live
    // MMC API (moroccomicrosoftcommunity.com/api) refreshes it.
    content: ContentController(
      offline: SnapshotContentRepository(),
      online: AppConfig.offlineOnly
          ? null
          : ApiContentRepository(baseUrl: AppConfig.apiBaseUrl),
    ),
    bookmarks: BookmarksController(store),
    settings: SettingsController(store),
  ));
}
