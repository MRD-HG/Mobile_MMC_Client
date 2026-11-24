import 'package:shared_preferences/shared_preferences.dart';

/// Tiny persistence abstraction so controllers are testable without plugins.
abstract class KeyValueStore {
  String? getString(String key);
  List<String>? getStringList(String key);
  Future<void> setString(String key, String value);
  Future<void> setStringList(String key, List<String> value);
  Future<void> remove(String key);
}

/// SharedPreferences-backed store. Writes are best-effort: a failed or
/// rejected write (MMC-017) must never crash the UI — the in-memory state
/// stays correct for the session and is re-written on the next change.
class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPrefsStore> create() async =>
      SharedPrefsStore(await SharedPreferences.getInstance());

  @override
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (_) {
      return null; // corrupted value of another type
    }
  }

  @override
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (_) {}
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    try {
      await _prefs.setStringList(key, value);
    } catch (_) {}
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (_) {}
  }
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
