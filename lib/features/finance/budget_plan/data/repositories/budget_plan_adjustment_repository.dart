// lib/features/finance/budget_plan/data/repositories/budget_plan_adjustment_repository.dart
//
// Repository — nhận DTO từ Service, chuyển thành Model cho Provider.

import '../services/budget_plan_adjustment_service.dart';
import '../models/budget_plan_adjustment_model.dart';

class BudgetPlanAdjustmentRepository {
  BudgetPlanAdjustmentRepository._();
  static final BudgetPlanAdjustmentRepository instance =
      BudgetPlanAdjustmentRepository._();

  final _service = BudgetPlanAdjustmentService.instance;

  Future<List<BudgetPlanAdjustmentModel>> getFollowing({
    required int year,
    required int month,
    int? status,
  }) async {
    final dtos = await _service.getFollowing(
      year: year,
      month: month,
      status: status,
    );
    return dtos.map(BudgetPlanAdjustmentModel.fromDto).toList();
  }

  Future<BudgetPlanAdjustmentDetailModel> getDetail(String id) async {
    final dto = await _service.getDetail(id);
    return BudgetPlanAdjustmentDetailModel.fromDto(dto);
  }

  Future<void> approve(String id) async => _service.approve(id);

  Future<void> review(String id) async => _service.review(id);

  Future<void> returnAdjustment(String id, String reason) async =>
      _service.returnAdjustment(id, reason);
}
