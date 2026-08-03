// lib/features/finance/budget_plan/providers/budget_plan_adjustment_provider.dart
//
// Provider — quản lý state danh sách bổ sung kế hoạch ngân sách.
// Bộ lọc theo năm/tháng (giống filter "Chọn năm" / "Chọn tháng" trên web).
//
// Kế thừa cùng FollowingListProviderBase với BudgetPlanProvider để dùng
// chung phần chống race-condition + search client-side, dù đây là 2 tài
// nguyên khác nhau (API, filter, model đều khác — xem giải thích trong
// phần trả lời bên dưới).

import 'following_list_provider_base.dart';
import '../data/models/budget_plan_adjustment_model.dart';
import '../data/repositories/budget_plan_adjustment_repository.dart';

class BudgetPlanAdjustmentProvider
    extends FollowingListProviderBase<BudgetPlanAdjustmentModel> {
  final _repo = BudgetPlanAdjustmentRepository.instance;

  // ── Bộ lọc ────────────────────────────────────────────────────────
  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  int? _statusFilter; // null = tất cả

  int get year => _year;
  int get month => _month;
  int? get statusFilter => _statusFilter;

  // Tổng tiền toàn danh sách đang hiển thị (theo filter)
  num get totalBudget => rawItems.fold(0, (sum, e) => sum + e.totalAmount);

  // ── Actions ───────────────────────────────────────────────────────
  void setYear(int y) {
    _year = y;
    load();
  }

  void setMonth(int m) {
    _month = m;
    load();
  }

  /// Đổi cả năm + tháng cùng lúc — chỉ gọi load() MỘT lần
  /// (tương tự setDateRange bên BudgetPlanProvider).
  void setYearMonth(int y, int m) {
    _year = y;
    _month = m;
    load();
  }

  void setStatusFilter(int? status) {
    _statusFilter = status;
    load();
  }

  // ── Load ──────────────────────────────────────────────────────────
  @override
  Future<List<BudgetPlanAdjustmentModel>> fetchItems() => _repo.getFollowing(
        year: _year,
        month: _month,
        status: _statusFilter,
      );

  @override
  bool matchesSearch(BudgetPlanAdjustmentModel item, String query) {
    return item.departmentDisplay.toLowerCase().contains(query) ||
        (item.departmentCode?.toLowerCase().contains(query) ?? false) ||
        (item.departmentName?.toLowerCase().contains(query) ?? false);
  }
}
