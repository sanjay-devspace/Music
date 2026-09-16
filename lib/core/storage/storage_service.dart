import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Minimal persistence abstraction used by [StorageService].
///
/// Kept intentionally small so the storage layer never leaks
/// `SharedPreferences` specifics into the app.
abstract class KeyValueStore {
  String? getString(String key);
  bool getBool(String key, {bool defaultValue});
  int? getInt(String key);
  double? getDouble(String key);

  Future<void> setString(String key, String value);
  Future<void> setBool(String key, bool value);
  Future<void> setInt(String key, int value);
  Future<void> setDouble(String key, double value);
  Future<void> remove(String key);
  Future<void> clear();
}

/// In-memory [KeyValueStore] used by tests and the noop path.
class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object> _data = {};

  @override
  String? getString(String key) => _data[key] as String?;
  @override
  bool getBool(String key, {bool defaultValue = false}) =>
      _data[key] as bool? ?? defaultValue;
  @override
  int? getInt(String key) => _data[key] as int?;
  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;
  @override
  Future<void> setBool(String key, bool value) async => _data[key] = value;
  @override
  Future<void> setInt(String key, int value) async => _data[key] = value;
  @override
  Future<void> setDouble(String key, double value) async => _data[key] = value;
  @override
  Future<void> remove(String key) async => _data.remove(key);
  @override
  Future<void> clear() async => _data.clear();
}

class _SharedPrefsStore implements KeyValueStore {
  _SharedPrefsStore(this._prefs);
  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);
  @override
  bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;
  @override
  int? getInt(String key) => _prefs.getInt(key);
  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}

/// Thin, cache-aware persistence wrapper.
///
/// All app-owned local state (theme, onboarding seen, cached metadata,
/// search history) flows through here so tests can substitute an in-memory
/// implementation.
class StorageService {
  StorageService([KeyValueStore? store]) : _store = store ?? MemoryKeyValueStore();

  /// In-memory instance for tests and extension points.
  StorageService.noop() : this(MemoryKeyValueStore());

  final KeyValueStore _store;
  static StorageService? _instance;

  static Future<StorageService> get instance async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = StorageService(_SharedPrefsStore(prefs));
    return _instance!;
  }

  static Future<void> ensureInitialized() async {
    await instance;
  }

  static void overrideInstance(StorageService service) => _instance = service;

  String? getString(String key) => _store.getString(key);
  bool getBool(String key, {bool defaultValue = false}) =>
      _store.getBool(key, defaultValue: defaultValue);
  int? getInt(String key) => _store.getInt(key);
  double? getDouble(String key) => _store.getDouble(key);

  Future<void> setString(String key, String value) => _store.setString(key, value);
  Future<void> setBool(String key, bool value) => _store.setBool(key, value);
  Future<void> setInt(String key, int value) => _store.setInt(key, value);
  Future<void> setDouble(String key, double value) => _store.setDouble(key, value);

  Future<void> setJson(String key, Object value) =>
      _store.setString(key, jsonEncode(value));

  Map<String, dynamic>? getJson(String key) {
    final raw = _store.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  List<Map<String, dynamic>>? getJsonList(String key) {
    final raw = _store.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return null;
  }

  Future<void> remove(String key) => _store.remove(key);
  Future<void> clear() => _store.clear();
}

/// Well-known keys.
abstract class StorageKeys {
  static const String onboardingSeen = 'onboarding_seen';
  static const String themeMode = 'theme_mode';
  static const String authSession = 'auth_session';
  static const String recentSearches = 'recent_searches';
  static const String activeProvider = 'active_music_provider';
  static const String lastHomeCache = 'home_cache_v1';
  static const String lastMetadataCache = 'metadata_cache_v1';
}