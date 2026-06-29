// lib/repositories/payment_repository.dart
//
// Trách nhiệm: gọi ApiClient, chuyển đổi JSON → PaymentModel.
// Không biết gì về UI, state, hay Navigator.

import '../services/api_client.dart';
import '../core/models/payment_model.dart';
import '../core/models/advance_model.dart';
// ← phải lên đầu file

class PaymentRepository {
  PaymentRepository._();
  static final PaymentRepository instance = PaymentRepository._();

  final _api = ApiClient.instance;

  // ── Danh sách ──────────────────────────────────────────────────────
  Future<PagedResult<PaymentListItem>> getList({
    required String endpoint,
    int page = 1,
    int pageSize = 20,
    int? status,
    String? search,
  }) async {
    final res = await _api.get(endpoint, params: {
      'PageIndex': page,
      'PageSize': pageSize,
      if (status != null) 'Status': status,
      if (search != null && search.isNotEmpty) 'Name': search,
    });

    final data = res['data'] as Map<String, dynamic>;
    final rawItems = data['items'] as List? ?? [];
    final totalCount = data['totalCount'] as int? ?? 0;

    return PagedResult(
      items: rawItems
          .map((j) => PaymentListItem.fromJson(j as Map<String, dynamic>))
          .toList(),
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
    );
  }

  // ── Chi tiết ───────────────────────────────────────────────────────
  Future<PaymentDetail> getDetail(String id) async {
    final res = await _api.get('/api/expense-payments/detail/$id');
    if (res['isSuccess'] != true) {
      throw RepositoryException(
          res['message'] as String? ?? 'Không tải được dữ liệu');
    }
    return PaymentDetail.fromJson(res['data'] as Map<String, dynamic>);
  }

  // ── Duyệt ──────────────────────────────────────────────────────────
  Future<void> approve(String id) async {
    final res = await _api.post('/api/expense-payments/$id/approve', body: {});
    if (res['isSuccess'] != true) {
      throw RepositoryException(res['message'] as String? ?? 'Duyệt thất bại');
    }
  }

  // ── Từ chối ────────────────────────────────────────────────────────
  Future<void> reject(String id, String reason) async {
    final res = await _api.post(
      '/api/expense-payments/$id/reject',
      body: {'reason': reason},
    );
    if (res['isSuccess'] != true) {
      throw RepositoryException(
          res['message'] as String? ?? 'Từ chối thất bại');
    }
  }
}

// ── AdvanceRepository ─────────────────────────────────────────────────
// Đặt cùng file vì logic gần giống, tránh tạo thêm file nhỏ

class AdvanceRepository {
  AdvanceRepository._();
  static final AdvanceRepository instance = AdvanceRepository._();

  final _api = ApiClient.instance;

  Future<PagedResult<AdvanceListItem>> getList({
    required String endpoint,
    int page = 1,
    int pageSize = 20,
    int? status,
    String? search,
  }) async {
    final res = await _api.get(endpoint, params: {
      'PageIndex': page,
      'PageSize': pageSize,
      if (status != null) 'Status': status,
      if (search != null && search.isNotEmpty) 'Name': search,
    });

    final data = res['data'] as Map<String, dynamic>;
    final rawItems = data['items'] as List? ?? [];
    final totalCount = data['totalCount'] as int? ?? 0;

    return PagedResult(
      items: rawItems
          .map((j) => AdvanceListItem.fromJson(j as Map<String, dynamic>))
          .toList(),
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<AdvanceDetail> getDetail(String id) async {
    final res = await _api.get('/api/advance-payments/$id/detail');
    if (res['isSuccess'] != true) {
      throw RepositoryException(
          res['message'] as String? ?? 'Không tải được dữ liệu');
    }
    return AdvanceDetail.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> approve(String id) async {
    final res = await _api.post('/api/advance-payments/$id/approve', body: {});
    if (res['isSuccess'] != true) {
      throw RepositoryException(res['message'] as String? ?? 'Duyệt thất bại');
    }
  }

  Future<void> reject(String id, String reason) async {
    final res = await _api.post(
      '/api/advance-payments/$id/reject',
      body: {'reason': reason},
    );
    if (res['isSuccess'] != true) {
      throw RepositoryException(
          res['message'] as String? ?? 'Từ chối thất bại');
    }
  }
}

// ── Shared types ──────────────────────────────────────────────────────
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  bool get hasMore => items.length < totalCount;
}

class RepositoryException implements Exception {
  final String message;
  const RepositoryException(this.message);
  @override
  String toString() => message;
}
