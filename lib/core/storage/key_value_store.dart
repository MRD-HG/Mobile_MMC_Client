import 'package:shared_preferences/shared_preferences.dart';

/// Tiny persistence abstraction so controllers are testable without plugins.
abstract class KeyValueStore {
  String? getString(String key);
  List<String>? getStringList(String key);
  Future<void> setString(String key, String value);
  Future<void> setStringList(String key, List<String> value);
  Future<void> remove(String key);
}

class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPrefsStore> create() async =>
      SharedPrefsStore(await SharedPreferences.getInstance());

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

class MemoryStore implements KeyValueStore {
  final Map<String, Object> _data = {};

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  List<String>? getStringList(String key) => (_data[key] as List<String>?)?.toList();

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  Future<void> setStringList(String key, List<String> value) async =>
      _data[key] = List<String>.of(value);

  @override
  Future<void> remove(String key) async => _data.remove(key);
}
