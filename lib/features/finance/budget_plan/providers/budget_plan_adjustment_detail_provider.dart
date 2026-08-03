// lib/features/finance/budget_plan/providers/budget_plan_adjustment_detail_provider.dart

import 'package:flutter/foundation.dart';
import '../data/models/budget_plan_adjustment_model.dart';
import '../data/repositories/budget_plan_adjustment_repository.dart';

class BudgetPlanAdjustmentDetailProvider extends ChangeNotifier {
  final _repo = BudgetPlanAdjustmentRepository.instance;

  BudgetPlanAdjustmentDetailModel? _detail;
  bool _loading = false;
  String? _error;
  bool _acting = false;

  BudgetPlanAdjustmentDetailModel? get detail => _detail;
  bool get loading => _loading;
  String? get error => _error;
  bool get acting => _acting;

  Future<void> load(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _detail = await _repo.getDetail(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> approve(String id) async {
    _acting = true;
    notifyListeners();
    try {
      await _repo.approve(id);
      await load(id);
      return true;
    } catch (e) {
      _error = e.toString();
      _acting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> review(String id) async {
    _acting = true;
    notifyListeners();
    try {
      await _repo.review(id);
      await load(id);
      return true;
    } catch (e) {
      _error = e.toString();
      _acting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(String id, String reason) async {
    _acting = true;
    notifyListeners();
    try {
      await _repo.returnAdjustment(id, reason);
      await load(id);
      return true;
    } catch (e) {
      _error = e.toString();
      _acting = false;
      notifyListeners();
      return false;
    }
  }
}
