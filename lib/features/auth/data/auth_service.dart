// lib/services/auth_service.dart

import '../../../core/network/api_client.dart';
import 'auth_storage.dart';

class AuthService implements TokenProvider {
  AuthService._();
  static final AuthService instance = AuthService._();

  // ── State in-memory ──────────────────────────────────────────────────
  String _accessToken = '';
  String _refreshToken = '';
  DateTime? _accessTokenExpiry;
  DateTime? _refreshTokenExpiry;
  String _fullName = '';
  String _userId = '';
  List<String> _roles = [];
  List<String> _permissions = [];

  // ── TokenProvider interface ──────────────────────────────────────────
  @override
  String get token => _accessToken;
  @override
  String get refreshToken => _refreshToken;
  @override
  bool get isLoggedIn => _accessToken.isNotEmpty;

  /// true nếu accessToken còn dưới 5 phút
  @override
  bool get isAccessTokenExpiringSoon {
    if (_accessTokenExpiry == null) return true;
    return _accessTokenExpiry!.difference(DateTime.now()).inMinutes < 5;
  }

  // ── Getters thêm ────────────────────────────────────────────────────
  String get fullName => _fullName;
  String get userId => _userId;
  List<String> get roles => _roles;
  List<String> get permissions => _permissions;

  bool get isSessionValid {
    if (_refreshTokenExpiry == null) return false;
    return DateTime.now().isBefore(_refreshTokenExpiry!);
  }

  // ── Khởi động app ────────────────────────────────────────────────────
  Future<void> loadFromStorage() async {
    _accessToken = await AuthStorage.getAccessToken() ?? '';
    _refreshToken = await AuthStorage.getRefreshToken() ?? '';
    _accessTokenExpiry = await AuthStorage.getAccessTokenExpiry();
    _refreshTokenExpiry = await AuthStorage.getRefreshTokenExpiry();
    _fullName = await AuthStorage.getFullName() ?? '';
    _userId = await AuthStorage.getUserId() ?? '';
    _roles = await AuthStorage.getRoles();

    // Đăng ký vào ApiClient sau khi load xong
    ApiClient.instance.registerTokenProvider(this);
  }

  // ── Login ─────────────────────────────────────────────────────────────
  Future<AuthResult> login(String employeeCode, String password) async {
    try {
      final res = await ApiClient.instance.postPublic(
        '/api/auth/login',
        body: {'employeeCode': employeeCode, 'password': password},
      );

      final data = res['data'] as Map<String, dynamic>?;
      if (data == null) {
        return AuthResult.failure('Phản hồi không hợp lệ từ server');
      }

      await _applyTokenData(data);

      // Đăng ký provider sau khi login thành công
      ApiClient.instance.registerTokenProvider(this);

      return AuthResult.success(
        fullName: _fullName,
        userId: _userId,
        roles: _roles,
        permissions: _permissions,
      );
    } on ApiException catch (e) {
      return AuthResult.failure(e.message);
    } catch (_) {
      return AuthResult.failure('Lỗi kết nối đến server');
    }
  }

  // ── Refresh token (gọi bởi ApiClient interceptor) ────────────────────
  @override
  Future<bool> doRefresh() async {
    if (_refreshToken.isEmpty) return false;

    // refreshToken đã hết hạn → không thử nữa
    if (_refreshTokenExpiry != null &&
        DateTime.now().isAfter(_refreshTokenExpiry!)) {
      await logout();
      return false;
    }

    try {
      final res = await ApiClient.instance.postPublic(
        '/api/auth/refresh-token',
        body: {'refreshToken': _refreshToken},
      );

      final data = res['data'] as Map<String, dynamic>?;
      if (data == null) return false;

      _accessToken = data['accessToken'] as String? ?? _accessToken;
      _accessTokenExpiry = _parseDate(data['accessTokenExpiresAt']);

      // Backend có thể cấp refreshToken mới (rotation) hoặc giữ cũ
      final newRefresh = data['refreshToken'] as String?;
      final newRefreshExpiry = _parseDate(data['refreshTokenExpiresAt']);
      if (newRefresh != null) _refreshToken = newRefresh;
      if (newRefreshExpiry != null) _refreshTokenExpiry = newRefreshExpiry;

      // Lưu lại storage
      if (newRefresh != null) {
        await AuthStorage.save(
          accessToken: _accessToken,
          refreshToken: _refreshToken,
          accessTokenExpiresAt: data['accessTokenExpiresAt'] ?? '',
          refreshTokenExpiresAt: data['refreshTokenExpiresAt'] ?? '',
          fullName: _fullName,
          userId: _userId,
          roles: _roles,
        );
      } else {
        await AuthStorage.updateAccessToken(
          accessToken: _accessToken,
          accessTokenExpiresAt: data['accessTokenExpiresAt'] ?? '',
        );
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    _accessToken = '';
    _refreshToken = '';
    _accessTokenExpiry = null;
    _refreshTokenExpiry = null;
    _fullName = '';
    _userId = '';
    _roles = [];
    _permissions = [];
    await AuthStorage.clear();
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  Future<void> _applyTokenData(Map<String, dynamic> data) async {
    _accessToken = data['accessToken'] as String? ?? '';
    _refreshToken = data['refreshToken'] as String? ?? '';
    _accessTokenExpiry = _parseDate(data['accessTokenExpiresAt']);
    _refreshTokenExpiry = _parseDate(data['refreshTokenExpiresAt']);
    _fullName = data['fullName'] as String? ?? 'Người dùng';
    _userId = data['userId']?.toString() ?? '';
    _roles = (data['roles'] as List?)?.cast<String>() ?? [];
    _permissions = (data['permissions'] as List?)?.cast<String>() ?? [];

    await AuthStorage.save(
      accessToken: _accessToken,
      refreshToken: _refreshToken,
      accessTokenExpiresAt: data['accessTokenExpiresAt'] ?? '',
      refreshTokenExpiresAt: data['refreshTokenExpiresAt'] ?? '',
      fullName: _fullName,
      userId: _userId,
      roles: _roles,
    );
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString())?.toLocal();
  }
}

// ── AuthResult ────────────────────────────────────────────────────────
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String fullName;
  final String userId;
  final List<String> roles;
  final List<String> permissions;

  const AuthResult._({
    required this.success,
    this.errorMessage,
    this.fullName = '',
    this.userId = '',
    this.roles = const [],
    this.permissions = const [],
  });

  factory AuthResult.success({
    required String fullName,
    required String userId,
    required List<String> roles,
    List<String> permissions = const [],
  }) =>
      AuthResult._(
        success: true,
        fullName: fullName,
        userId: userId,
        roles: roles,
        permissions: permissions,
      );

  factory AuthResult.failure(String message) =>
      AuthResult._(success: false, errorMessage: message);
}
