import 'dart:async';

import 'package:flutter/material.dart';

import '../core/storage/key_value_store.dart';
import '../data/repositories/content_repository.dart';

enum LoadStatus { idle, loading, ready, error }

/// Offline-first content loading:
/// 1. the bundled snapshot is shown immediately (works with no network);
/// 2. live data from the MMC API replaces it in the background.
class ContentController extends ChangeNotifier {
  ContentController({required this.offline, this.online});

  final ContentRepository offline;
  final ContentRepository? online;

  LoadStatus _status = LoadStatus.idle;
  ContentBundle? _data;
  Object? _error;
  bool _refreshing = false;
  bool _refreshFailed = false;
  Future<void>? _initial;

  LoadStatus get status => _status;
  ContentBundle? get data => _data;
  Object? get error => _error;

  /// True while live data is being fetched.
  bool get refreshing => _refreshing;

  /// True when the last live refresh failed (the snapshot is shown).
  bool get refreshFailed => _refreshFailed;

  /// Loads offline data once, then refreshes from the API in the background.
  /// Completes as soon as something can be displayed.
  Future<void> load() => _initial ??= _loadInitial();

  Future<void> _loadInitial() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _data = await offline.load();
      _status = LoadStatus.ready;
    } catch (e) {
      _error = e;
    }
    notifyListeners();
    if (online != null) {
      // Not awaited: the UI is usable while live data arrives.
      unawaited(refresh());
    } else if (_data == null) {
      _status = LoadStatus.error;
      notifyListeners();
    }
  }

  /// Fetches live data. Keeps the current data if the network fails.
  Future<void> refresh() async {
    final repo = online;
    if (repo == null || _refreshing) return;
    _refreshing = true;
    notifyListeners();
    try {
      _data = await repo.load();
      _status = LoadStatus.ready;
      _refreshFailed = false;
      _error = null;
    } catch (e) {
      _refreshFailed = true;
      if (_data == null) {
        _error = e;
        _status = LoadStatus.error;
      }
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  /// Retry button: reload everything if nothing is shown, else refresh.
  Future<void> retry() async {
    if (_data == null) {
      _initial = null;
      _status = LoadStatus.idle;
      await load();
    } else {
      await refresh();
    }
  }
}

/// Saved events, persisted on device.
class BookmarksController extends ChangeNotifier {
  BookmarksController(this._store)
      : _ids = (_store.getStringList(_key) ?? const <String>[]).toSet();

  static const _key = 'bookmarks.events';
  final KeyValueStore _store;
  final Set<String> _ids;

  Set<String> get ids => Set.unmodifiable(_ids);

  bool isSaved(String eventId) => _ids.contains(eventId);

  Future<void> toggle(String eventId) async {
    if (!_ids.remove(eventId)) _ids.add(eventId);
    notifyListeners();
    await _store.setStringList(_key, _ids.toList());
  }
}

/// Theme, language and topic preferences.
class SettingsController extends ChangeNotifier {
  SettingsController(this._store)
      : _themeMode = _parseTheme(_store.getString(_themeKey)),
        _localeCode = _store.getString(_localeKey),
        _topics = (_store.getStringList(_topicsKey) ?? const <String>[]).toSet();

  static const _themeKey = 'settings.theme';
  static const _localeKey = 'settings.locale';
  static const _topicsKey = 'settings.topics';

  final KeyValueStore _store;
  ThemeMode _themeMode;
  String? _localeCode;
  final Set<String> _topics;

  ThemeMode get themeMode => _themeMode;

  /// Null → follow the device language.
  Locale? get locale => _localeCode == null ? null : Locale(_localeCode!);
  String? get localeCode => _localeCode;
  Set<String> get favoriteTopics => Set.unmodifiable(_topics);

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _store.setString(_themeKey, mode.name);
  }

  Future<void> setLocaleCode(String? code) async {
    _localeCode = code;
    notifyListeners();
    if (code == null) {
      await _store.remove(_localeKey);
    } else {
      await _store.setString(_localeKey, code);
    }
  }

  Future<void> toggleTopic(String topic) async {
    if (!_topics.remove(topic)) _topics.add(topic);
    notifyListeners();
    await _store.setStringList(_topicsKey, _topics.toList());
  }

  static ThemeMode _parseTheme(String? value) => ThemeMode.values.firstWhere(
        (m) => m.name == value,
        orElse: () => ThemeMode.system,
      );
}
