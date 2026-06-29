// lib/providers/auth_provider.dart
//
// Vị trí : lib/providers/    ← Provider tầng toàn cục
// Nhiệm vụ: quản lý state xác thực — isLoggedIn, fullName, roles
// Dùng bởi: SplashScreen, LoginScreen, HomeScreen

import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _auth = AuthService.instance;

  // ── State ─────────────────────────────────────────────────────────
  bool _loading = false;
  String? _error;

  // ── Getters — đọc trực tiếp từ AuthService (single source of truth)
  bool get isLoggedIn => _auth.isLoggedIn;
  bool get isSession => _auth.isSessionValid;
  String get fullName => _auth.fullName;
  String get userId => _auth.userId;
  List<String> get roles => _auth.roles;
  List<String> get permissions => _auth.permissions;
  bool get loading => _loading;
  String? get error => _error;

  // ── Initials cho avatar ───────────────────────────────────────────
  String get initials {
    final name = _auth.fullName.trim();
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name[0].toUpperCase();
  }

  // ── Kiểm tra quyền ───────────────────────────────────────────────
  bool hasPermission(String permission) =>
      _auth.permissions.contains(permission);

  bool hasRole(String role) => _auth.roles.contains(role);

  // ── Khởi động app: load session từ storage ────────────────────────
  Future<void> init() async {
    _loading = true;
    notifyListeners();

    await _auth.loadFromStorage();

    _loading = false;
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────
  Future<bool> login(String employeeCode, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _auth.login(employeeCode, password);

    _loading = false;
    if (!result.success) {
      _error = result.errorMessage;
    }
    notifyListeners();

    return result.success;
  }

  // ── Logout ────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.logout();
    notifyListeners();
  }

  // ── Xoá lỗi (sau khi hiển thị cho user) ──────────────────────────
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
