// lib/features/finance/budget_plan/data/budget_plan_repository.dart
//
// Repository — nhận DTO từ Service, chuyển thành Model cho Provider.
// Đây là tầng duy nhất biết cả DTO lẫn Model.

import '../services/budget_plan_service.dart';
//import 'budget_plan_dto.dart';

import '../models/budget_plan_model.dart';

class BudgetPlanRepository {
  BudgetPlanRepository._();
  static final BudgetPlanRepository instance = BudgetPlanRepository._();

  final _service = BudgetPlanService.instance;

  Future<List<BudgetPlanModel>> getFollowing({
    required DateTime fromDate,
    required DateTime toDate,
    int? status,
  }) async {
    final dtos = await _service.getFollowing(
      fromDate: fromDate,
      toDate: toDate,
      status: status,
    );
    // DTO → Model
    return dtos.map(BudgetPlanModel.fromDto).toList();
  }

  Future<BudgetPlanDetailModel> getDetail(String id) async {
    final dto = await _service.getDetail(id);
    return BudgetPlanDetailModel.fromDto(dto);
  }

  Future<void> review(String id) async => _service.review(id);
  Future<void> approve(String id) async => _service.approve(id);

  Future<void> returnPlan(String id, String reason) async =>
      _service.returnPlan(id, reason);
}

class BudgetPlanException implements Exception {
  final String message;
  const BudgetPlanException(this.message);
  @override
  String toString() => message;
}
