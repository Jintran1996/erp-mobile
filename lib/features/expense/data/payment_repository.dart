// lib/repositories/payment_repository.dart

import '../../../services/api_client.dart';
import 'advance_model.dart';
import 'advance_settlement_model.dart';
import 'payment_model.dart'; // ✅ Fix #1: chữ thường

class PaymentRepository {
  PaymentRepository._();
  static final PaymentRepository instance = PaymentRepository._();
  final _api = ApiClient.instance;

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
      if (search != null && search.isNotEmpty)
        _isSubId(search) ? 'subId' : 'name': search,
    });
    final data = res['data'] as Map<String, dynamic>;
    return PagedResult(
      items: (data['items'] as List? ?? [])
          .map((j) => PaymentListItem.fromJson(j as Map<String, dynamic>))
          .toList(),
      totalCount: data['totalCount'] as int? ?? 0,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<PaymentDetail> getDetail(String id) async {
    final res = await _api.get('/api/expense-payments/detail/$id');
    if (res['isSuccess'] != true)
      throw RepositoryException(res['message'] as String? ?? 'Lỗi');
    return PaymentDetail.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> approve(String id) async {
    final res = await _api.post('/api/expense-payments/$id/approve', body: {});
    if (res['isSuccess'] != true)
      throw RepositoryException(res['message'] as String? ?? 'Duyệt thất bại');
  }

  Future<void> reject(String id, String reason) async {
    final res = await _api
        .post('/api/expense-payments/$id/reject', body: {'reason': reason});
    if (res['isSuccess'] != true)
      throw RepositoryException(
          res['message'] as String? ?? 'Từ chối thất bại');
  }
}

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
      if (search != null && search.isNotEmpty)
        _isSubId(search) ? 'subId' : 'name': search,
    });
    final data = res['data'] as Map<String, dynamic>;
    return PagedResult(
      items: (data['items'] as List? ?? [])
          .map((j) => AdvanceListItem.fromJson(j as Map<String, dynamic>))
          .toList(),
      totalCount: data['totalCount'] as int? ?? 0,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<AdvanceDetail> getDetail(String id) async {
    final res = await _api.get('/api/advance-payments/$id/detail');
    if (res['isSuccess'] != true)
      throw RepositoryException(res['message'] as String? ?? 'Lỗi');
    return AdvanceDetail.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> approve(String id) async {
    final res = await _api.post('/api/advance-payments/$id/approve', body: {});
    if (res['isSuccess'] != true)
      throw RepositoryException(res['message'] as String? ?? 'Duyệt thất bại');
  }

  Future<void> reject(String id, String reason) async {
    final res = await _api
        .post('/api/advance-payments/$id/reject', body: {'reason': reason});
    if (res['isSuccess'] != true)
      throw RepositoryException(
          res['message'] as String? ?? 'Từ chối thất bại');
  }
}

class SettlementRepository {
  SettlementRepository._();
  static final SettlementRepository instance = SettlementRepository._();
  final _api = ApiClient.instance;

  Future<PagedResult<SettlementListItem>> getList({
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
      if (search != null && search.isNotEmpty)
        _isSubId(search) ? 'subId' : 'name': search,
    });
    final data = res['data'] as Map<String, dynamic>;
    return PagedResult(
      items: (data['items'] as List? ?? [])
          .map((j) => SettlementListItem.fromJson(j as Map<String, dynamic>))
          .toList(),
      totalCount: data['totalCount'] as int? ?? 0,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<SettlementDetail> getDetail(String id) async {
    final res = await _api.get('/api/advance-settlements/$id/detail');
    if (res['isSuccess'] != true)
      throw RepositoryException(res['message'] as String? ?? 'Lỗi');
    return SettlementDetail.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> approve(String id) async {
    final res =
        await _api.post('/api/advance-settlements/$id/approve', body: {});
    if (res['isSuccess'] != true)
      throw RepositoryException(res['message'] as String? ?? 'Duyệt thất bại');
  }

  Future<void> reject(String id, String reason) async {
    final res = await _api
        .post('/api/advance-settlements/$id/reject', body: {'reason': reason});
    if (res['isSuccess'] != true)
      throw RepositoryException(
          res['message'] as String? ?? 'Từ chối thất bại');
  }
}

// ── Shared types ──────────────────────────────────────────────────────
class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;
  const PagedResult(
      {required this.items,
      required this.totalCount,
      required this.page,
      required this.pageSize});
  bool get hasMore => items.length < totalCount;
}

class RepositoryException implements Exception {
  final String message;
  const RepositoryException(this.message);
  @override
  String toString() => message;
}

bool _isSubId(String s) => RegExp(r'^[0-9]+$').hasMatch(s.trim());
