// lib/services/api_client.dart
//
// Trách nhiệm DUY NHẤT: HTTP transport + tự động refresh token.
//
// Để tránh circular import (ApiClient ↔ AuthService), dùng interface
// TokenProvider. AuthService implements TokenProvider và tự đăng ký
// vào ApiClient.instance khi khởi động.
//
// Flow tự động refresh:
//   1. onRequest  → token sắp hết (< 5 phút) → proactive refresh trước
//   2. onError 401 → token hết đột xuất → reactive refresh + retry
//   3. Cả 2 fail  → logout + ném SessionExpiredException

import 'package:dio/dio.dart';
import '../config/app_config.dart';

// ── Interface: ApiClient chỉ biết về interface này, không biết AuthService ──
abstract class TokenProvider {
  String get token;
  String get refreshToken;
  bool get isLoggedIn;
  bool get isAccessTokenExpiringSoon;

  /// Thực hiện refresh → trả true nếu thành công
  Future<bool> doRefresh();

  /// Xoá session (gọi khi cả refresh cũng fail)
  Future<void> logout();
}

// ── ApiClient ─────────────────────────────────────────────────────────
class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  static final ApiClient instance = ApiClient._();
  late final Dio _dio;

  // Dio riêng không có interceptor → dùng để gọi login & refresh
  // tránh vòng lặp vô hạn nếu refresh endpoint cũng trả 401
  final Dio _publicDio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // Đăng ký từ main() sau khi AuthService.instance khởi tạo xong
  TokenProvider? _tokenProvider;
  void registerTokenProvider(TokenProvider provider) {
    _tokenProvider = provider;
  }

  bool _isRefreshing = false;

  // ── Interceptor REQUEST ───────────────────────────────────────────────
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final auth = _tokenProvider;
    if (auth == null || !auth.isLoggedIn) {
      handler.next(options);
      return;
    }

    // Proactive: token sắp hết → refresh trước khi gửi
    if (auth.isAccessTokenExpiringSoon && !_isRefreshing) {
      _isRefreshing = true;
      final ok = await auth.doRefresh();
      _isRefreshing = false;

      if (!ok) {
        await auth.logout();
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: SessionExpiredException(),
        ));
        return;
      }
    }

    options.headers['Authorization'] = 'Bearer ${auth.token}';
    handler.next(options);
  }

  // ── Interceptor ERROR ─────────────────────────────────────────────────
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    // Chỉ xử lý 401
    if (error.response?.statusCode != 401) {
      handler.next(error);
      return;
    }

    final auth = _tokenProvider;
    if (auth == null || _isRefreshing || auth.refreshToken.isEmpty) {
      handler.next(error);
      return;
    }

    // Reactive: thử refresh 1 lần rồi retry
    _isRefreshing = true;
    final ok = await auth.doRefresh();
    _isRefreshing = false;

    if (!ok) {
      await auth.logout();
      handler.reject(DioException(
        requestOptions: error.requestOptions,
        type: DioExceptionType.cancel,
        error: SessionExpiredException(),
      ));
      return;
    }

    // Retry request gốc với token mới
    try {
      final opts = error.requestOptions
        ..headers['Authorization'] = 'Bearer ${auth.token}';
      final response = await _dio.fetch(opts);
      handler.resolve(response);
    } catch (e) {
      handler.next(error);
    }
  }

  // ── Public API ────────────────────────────────────────────────────────

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final response = await _dio.get(path, queryParameters: params);
    return response.data;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post(path, data: body);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is SessionExpiredException) rethrow;
      return {
        'isSuccess': false,
        'message': e.response?.data?['message'] ?? 'Lỗi kết nối',
      };
    }
  }

  /// Dùng cho login & refresh — không qua interceptor auth
  Future<Map<String, dynamic>> postPublic(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _publicDio.post(path, data: body);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ?? 'Lỗi kết nối đến server';
      throw ApiException(msg, statusCode: e.response?.statusCode);
    }
  }
}

// ── Exceptions ────────────────────────────────────────────────────────
class SessionExpiredException implements Exception {
  @override
  String toString() => 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
