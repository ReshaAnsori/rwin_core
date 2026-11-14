import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Keys that are stored in Secure Storage (Keystore / Keychain).
/// All other keys go to SharedPreferences.
/// Add your own keys by extending this enum or by passing raw string keys
/// to the low-level `setRaw` / `getRaw` helpers.
enum StorageKey {
  token('rwin.token'),
  refreshToken('rwin.refresh_token'),
  deviceId('rwin.device_id'),
  sessionId('rwin.session_id'),
  isDark('rwin.is_dark'),
  hasOnboarded('rwin.has_onboarded');

  const StorageKey(this.value);
  final String value;
}

/// A unified key-value store that transparently routes sensitive keys to
/// [FlutterSecureStorage] (Keystore on Android, Keychain on iOS) and
/// everything else to [SharedPreferences].
///
/// Only [StorageKey.token] and [StorageKey.refreshToken] are stored securely
/// by default. Extend [_secureKeys] in a subclass if you need more secure keys.
class StorageHandler {
  StorageHandler._();

  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Fallback instance with legacy iOS accessibility for migrating tokens
  /// written by older app versions (accessibility: unlocked).
  static const FlutterSecureStorage _legacySecure = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked),
  );

  static const Set<StorageKey> _secureKeys = {
    StorageKey.token,
    StorageKey.refreshToken,
  };

  static bool _isSecure(StorageKey key) => _secureKeys.contains(key);

  // ─── Write ────────────────────────────────────────────────────────────────

  static Future<void> set<T>(StorageKey key, T value) async {
    if (_isSecure(key)) {
      // Delete first to avoid Keychain errSecDuplicateItem on iOS
      try {
        await _secure.delete(key: key.value);
      } catch (_) {}
      await _secure.write(key: key.value, value: value.toString());
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final k = key.value;
    if (value is String) {
      await prefs.setString(k, value);
    } else if (value is bool) {
      await prefs.setBool(k, value);
    } else if (value is int) {
      await prefs.setInt(k, value);
    } else if (value is double) {
      await prefs.setDouble(k, value);
    } else if (value is DateTime) {
      await prefs.setString(k, value.toIso8601String());
    } else if (value is List<String>) {
      await prefs.setStringList(k, value);
    } else {
      throw UnsupportedError(
          'StorageHandler.set: unsupported type ${value.runtimeType}');
    }
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  /// Returns the stored value or a sensible default for type [T].
  /// Pass [defaultValue] to override the built-in default.
  static Future<T> get<T>(StorageKey key, {T? defaultValue}) async {
    final fallback = defaultValue ?? _defaultFor<T>();

    if (_isSecure(key)) return _readSecure<T>(key, fallback);

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.get(key.value);
      if (raw == null) return fallback;
      if (raw is List) return raw.cast<String>() as T;
      if (T == DateTime && raw is String) {
        return (DateTime.tryParse(raw) ?? fallback as DateTime) as T;
      }
      return raw as T;
    } catch (_) {
      return fallback;
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  static Future<void> delete(StorageKey key) async {
    if (_isSecure(key)) {
      await _secure.delete(key: key.value);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key.value);
  }

  /// Clears session credentials only (token + refreshToken + sessionId).
  /// Preserves user preferences such as theme and onboarding flag.
  static Future<void> clearSession() async {
    try {
      await _secure.delete(key: StorageKey.token.value);
      await _secure.delete(key: StorageKey.refreshToken.value);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKey.sessionId.value);
    } catch (_) {}
  }

  /// Wipes all storage — both secure and shared preferences.
  static Future<void> clearAll() async {
    await _secure.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ─── Device ID ────────────────────────────────────────────────────────────

  /// Returns a stable UUID that persists across app updates but is cleared
  /// on uninstall (stored in SharedPreferences, not Keychain).
  static Future<String> getOrCreateDeviceId() async {
    final saved = await get<String>(StorageKey.deviceId);
    if (saved.isNotEmpty) return saved;
    final id = const Uuid().v4();
    await set(StorageKey.deviceId, id);
    return id;
  }

  // ─── Internals ────────────────────────────────────────────────────────────

  static Future<T> _readSecure<T>(StorageKey key, T fallback) async {
    try {
      final v = await _secure.read(key: key.value);
      if (v != null) return _fromString<T>(v, fallback);
    } catch (_) {}

    // iOS legacy migration: try unlocked accessibility
    if (Platform.isIOS) {
      try {
        final legacy = await _legacySecure.read(key: key.value);
        if (legacy != null) {
          try {
            await _secure.delete(key: key.value);
          } catch (_) {}
          await _secure.write(key: key.value, value: legacy);
          return _fromString<T>(legacy, fallback);
        }
      } catch (_) {}
    }

    return fallback;
  }

  static T _fromString<T>(String v, T fallback) {
    try {
      if (T == String) return v as T;
      if (T == bool) return (v.toLowerCase() == 'true') as T;
      if (T == int) return (int.tryParse(v) ?? fallback as int) as T;
      if (T == double) return (double.tryParse(v) ?? fallback as double) as T;
      if (T == DateTime) {
        return (DateTime.tryParse(v) ?? fallback as DateTime) as T;
      }
    } catch (_) {}
    return fallback;
  }

  static T _defaultFor<T>() {
    if (T == String) return '' as T;
    if (T == bool) return false as T;
    if (T == int) return 0 as T;
    if (T == double) return 0.0 as T;
    if (T == DateTime) return DateTime.now() as T;
    if (T == List || T == List<String>) return <String>[] as T;
    throw UnsupportedError('StorageHandler: no default for type $T');
  }
}

/// Extension so callers can write `token.hasValue` after `get<String>(...)`.
extension StorageStringEx on String {
  bool get hasValue => isNotEmpty;
}
