// lib/features/finance/budget_plan/data/services/budget_plan_adjustment_service.dart
//
// Service — gọi API bổ sung kế hoạch ngân sách, trả về DTO thô.

import '../../../../../core/network/api_client.dart';
import '../dtos/budget_plan_adjustment_dto.dart';

class BudgetPlanAdjustmentService {
  BudgetPlanAdjustmentService._();
  static final BudgetPlanAdjustmentService instance =
      BudgetPlanAdjustmentService._();

  final _api = ApiClient.instance;

  // ── GET /api/budget-plan-adjustments/following?year=&month= ────────
  Future<List<BudgetPlanAdjustmentDto>> getFollowing({
    required int year,
    required int month,
    int? status,
  }) async {
    final res = await _api.get('/api/budget-plan-adjustments/following',
        params: {'year': year, 'month': month});

    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Không tải được dữ liệu');
    }

    final raw = res['data'];
    final list = (raw is List ? raw : []);
    return list
        .map((j) => BudgetPlanAdjustmentDto.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // ── GET /api/budget-plan-adjustments/{id}/detail ──────────────────
  Future<BudgetPlanAdjustmentDetailDto> getDetail(String id) async {
    final res = await _api.get('/api/budget-plan-adjustments/$id/detail');
    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Không tải được dữ liệu');
    }
    return BudgetPlanAdjustmentDetailDto.fromJson(
        res['data'] as Map<String, dynamic>);
  }

  // ── POST /api/budget-plan-adjustments/{id}/approve ────────────────
  Future<void> approve(String id) async {
    final res =
        await _api.post('/api/budget-plan-adjustments/$id/approve', body: {});
    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Duyệt thất bại');
    }
  }

  // ── POST /api/budget-plan-adjustments/{id}/review ─────────────────
  Future<void> review(String id) async {
    final res =
        await _api.post('/api/budget-plan-adjustments/$id/review', body: {});
    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Xem xét thất bại');
    }
  }

  // ── POST /api/budget-plan-adjustments/{id}/return ─────────────────
  Future<void> returnAdjustment(String id, String reason) async {
    final res = await _api.post('/api/budget-plan-adjustments/$id/return',
        body: {'reason': reason});
    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Trả lại thất bại');
    }
  }

  // ── POST /api/budget-plan-adjustments/$id/cancel ───────────────────────────
  Future<void> cancelAdjustment(String id, String reason) async {
    final res = await _api.post('/api/budget-plan-adjustments/$id/cancel',
        body: {'reason': reason});
    if (res['isSuccess'] != true) {
      throw Exception(res['message'] as String? ?? 'Hủy thất bại');
    }
  }
}
