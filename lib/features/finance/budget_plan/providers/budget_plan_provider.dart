// lib/features/finance/budget_plan/providers/budget_plan_provider.dart
//
// Provider — quản lý state danh sách kế hoạch ngân sách.
// Screen chỉ watch provider, không biết về Repository hay DTO.

import '../data/models/budget_plan_model.dart';
import '../data/repositories/budget_plan_repository.dart';
import 'following_list_provider_base.dart';

class BudgetPlanProvider extends FollowingListProviderBase<BudgetPlanModel> {
  final _repo = BudgetPlanRepository.instance;

  // ── Bộ lọc ────────────────────────────────────────────────────────
  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _toDate = DateTime(
      DateTime.now().year, DateTime.now().month + 1, 0); // ngày cuối tháng
  int? _statusFilter; // null = tất cả

  DateTime get fromDate => _fromDate;
  DateTime get toDate => _toDate;
  int? get statusFilter => _statusFilter;

  // Tổng tiền toàn danh sách đang hiển thị (theo filter, KHÔNG theo search
  // để người dùng luôn thấy tổng đúng theo bộ lọc thời gian/trạng thái).
  num get totalBudget => rawItems.fold(0, (sum, e) => sum + e.totalAmount);
  num get totalUsed => rawItems.fold(0, (sum, e) => sum + e.usedAmount);

  // ── Actions ───────────────────────────────────────────────────────
  void setFromDate(DateTime d) {
    _fromDate = d;
    load();
  }

  void setToDate(DateTime d) {
    _toDate = d;
    load();
  }

  /// Đổi cả khoảng ngày cùng lúc — chỉ gọi load() MỘT lần.
  /// Ưu tiên dùng hàm này thay vì gọi setFromDate + setToDate liên tiếp,
  /// vì gọi riêng lẻ sẽ bắn 2 request load() không cần thiết.
  void setDateRange(DateTime from, DateTime to) {
    _fromDate = from;
    _toDate = to;
    load();
  }

  void setStatusFilter(int? status) {
    _statusFilter = status;
    load();
  }

  // ── Load ──────────────────────────────────────────────────────────
  @override
  Future<List<BudgetPlanModel>> fetchItems() => _repo.getFollowing(
        fromDate: _fromDate,
        toDate: _toDate,
        status: _statusFilter,
      );

  @override
  bool matchesSearch(BudgetPlanModel item, String query) {
    return item.departmentDisplay.toLowerCase().contains(query) ||
        (item.departmentCode?.toLowerCase().contains(query) ?? false) ||
        (item.departmentName?.toLowerCase().contains(query) ?? false);
  }
}
