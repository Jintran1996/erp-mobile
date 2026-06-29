// lib/services/auth_storage.dart
//
// Lưu/đọc toàn bộ session xuống SharedPreferences.
// Chỉ biết về storage — không có business logic.

import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _keyAccessToken = 'auth_access_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyAccessTokenExpiry = 'auth_access_token_expiry'; // ISO-8601
  static const _keyRefreshTokenExpiry = 'auth_refresh_token_expiry'; // ISO-8601
  static const _keyFullName = 'auth_full_name';
  static const _keyUserId = 'auth_user_id';
  static const _keyRoles = 'auth_roles'; // JSON string list

  // ── Lưu toàn bộ session sau login / sau refresh ──────────────────────
  static Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String accessTokenExpiresAt, // "2026-06-26T04:57:01.372Z"
    required String refreshTokenExpiresAt,
    required String fullName,
    String userId = '',
    List<String> roles = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_keyAccessToken, accessToken),
      prefs.setString(_keyRefreshToken, refreshToken),
      prefs.setString(_keyAccessTokenExpiry, accessTokenExpiresAt),
      prefs.setString(_keyRefreshTokenExpiry, refreshTokenExpiresAt),
      prefs.setString(_keyFullName, fullName),
      prefs.setString(_keyUserId, userId),
      prefs.setString(_keyRoles, roles.join(',')),
    ]);
  }

  // ── Đọc từng field ───────────────────────────────────────────────────
  static Future<String?> getAccessToken() async =>
      (await _prefs()).getString(_keyAccessToken);

  static Future<String?> getRefreshToken() async =>
      (await _prefs()).getString(_keyRefreshToken);

  static Future<DateTime?> getAccessTokenExpiry() async {
    final raw = (await _prefs()).getString(_keyAccessTokenExpiry);
    return raw != null ? DateTime.tryParse(raw)?.toLocal() : null;
  }

  static Future<DateTime?> getRefreshTokenExpiry() async {
    final raw = (await _prefs()).getString(_keyRefreshTokenExpiry);
    return raw != null ? DateTime.tryParse(raw)?.toLocal() : null;
  }

  static Future<String?> getFullName() async =>
      (await _prefs()).getString(_keyFullName);

  static Future<String?> getUserId() async =>
      (await _prefs()).getString(_keyUserId);

  static Future<List<String>> getRoles() async {
    final raw = (await _prefs()).getString(_keyRoles) ?? '';
    return raw.isEmpty ? [] : raw.split(',');
  }

  // ── Chỉ cập nhật accessToken sau khi refresh ─────────────────────────
  static Future<void> updateAccessToken({
    required String accessToken,
    required String accessTokenExpiresAt,
  }) async {
    final prefs = await _prefs();
    await Future.wait([
      prefs.setString(_keyAccessToken, accessToken),
      prefs.setString(_keyAccessTokenExpiry, accessTokenExpiresAt),
    ]);
  }

  // ── Xóa khi logout ───────────────────────────────────────────────────
  static Future<void> clear() async {
    final prefs = await _prefs();
    await Future.wait([
      prefs.remove(_keyAccessToken),
      prefs.remove(_keyRefreshToken),
      prefs.remove(_keyAccessTokenExpiry),
      prefs.remove(_keyRefreshTokenExpiry),
      prefs.remove(_keyFullName),
      prefs.remove(_keyUserId),
      prefs.remove(_keyRoles),
    ]);
  }

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();
}
