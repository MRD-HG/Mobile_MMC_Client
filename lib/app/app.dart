import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/l10n/strings.dart';
import 'app_scope.dart';
import 'controllers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// The one and only MaterialApp.
class MmcApp extends StatelessWidget {
  const MmcApp({
    super.key,
    required this.content,
    required this.bookmarks,
    required this.settings,
    this.clock = DateTime.now,
    this.initialRoute = AppRouter.splash,
  });

  final ContentController content;
  final BookmarksController bookmarks;
  final SettingsController settings;
  final DateTime Function() clock;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      content: content,
      bookmarks: bookmarks,
      settings: settings,
      clock: clock,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          title: 'MMC',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: S.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: initialRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
          // Fixed-height carousels now grow with the text scale, so the
          // clamp only caps extreme values instead of limiting accessibility.
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(
                textScaler: mq.textScaler.clamp(maxScaleFactor: 2.0),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
