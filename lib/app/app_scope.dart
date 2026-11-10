import 'package:flutter/widgets.dart';

import 'controllers.dart';

/// Dependency container available to the whole widget tree.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.content,
    required this.bookmarks,
    required this.settings,
    required this.clock,
    required super.child,
  });

  final ContentController content;
  final BookmarksController bookmarks;
  final SettingsController settings;

  /// Injectable "now" so tests are deterministic.
  final DateTime Function() clock;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      content != oldWidget.content ||
      bookmarks != oldWidget.bookmarks ||
      settings != oldWidget.settings;
}
