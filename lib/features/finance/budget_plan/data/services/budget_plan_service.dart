// lib/features/finance/budget_plan/data/budget_plan_service.dart
//
// Service — gọi API, trả về DTO thô.
// Không biết gì về Model hay UI.

import 'package:intl/intl.dart';
import '../../../../../core/network/api_client.dart';
import '../dtos/budget_plan_dto.dart';

class BudgetPlanService {
  BudgetPlanService._();
  static final BudgetPlanService instance = BudgetPlanService._();

  final _api = ApiClient.instance;

  // ── GET /api/budget-plans/following ──────────────────────────────
  Future<List<BudgetPlanDto>> getFollowing({
    required DateTime fromDate,
    required DateTime toDate,
    int? status,
  }) async {
    final fmt = DateFormat('yyyy-MM-dd');
    final res = await _api.get('/api/budget-plans/following', params: {
      'fromDate': fmt.format(fromDate),
      'toDate': fmt.format(toDate),
      if (status != null) 'status': status,
    });

    final raw = res['data'];
    final list = (raw is List ? raw : []);
    return list
        .map((j) => BudgetPlanDto.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // ── GET /api/budget-plans/{id}/detail ────────────────────────────
  Future<BudgetPlanDetailDto> getDetail(String id) async {
    final res = await _api.get('/api/budget-plans/$id/detail');
    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Không tải được dữ liệu');
    }
    return BudgetPlanDetailDto.fromJson(res['data'] as Map<String, dynamic>);
  }

  // ── POST /api/budget-plans/{id}/review ──────────────────────────
  Future<void> review(String id) async {
    final res = await _api.post('/api/budget-plans/$id/review', body: {});
    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Xem xét thất bại');
    }
  }

  // ── POST /api/budget-plans/{id}/approve ──────────────────────────
  Future<void> approve(String id) async {
    final res = await _api.post('/api/budget-plans/$id/approve', body: {});
    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Duyệt thất bại');
    }
  }

  // ── POST /api/budget-plans/{id}/return ───────────────────────────
  Future<void> returnPlan(String id, String reason) async {
    final res = await _api
        .post('/api/budget-plans/$id/return', body: {'reason': reason});
    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Trả lại thất bại');
    }
  }

  // ── POST /api/budget-plans/{id}/cancel ───────────────────────────
  Future<void> cancelPlan(String id, String reason) async {
    final res = await _api
        .post('/api/budget-plans/$id/cancel', body: {'reason': reason});
    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Hủy thất bại');
    }
  }
}
