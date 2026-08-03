// lib/core/providers/following_list_provider_base.dart
//
// Base class generic cho các provider dạng "danh sách đang theo dõi"
// (following list) có bộ lọc riêng + load() bất đồng bộ, ví dụ:
// BudgetPlanProvider, BudgetPlanAdjustmentProvider...
//
// Cung cấp sẵn 2 việc mà PaymentListProvider đã làm tốt nhưng
// BudgetPlanProvider / BudgetPlanAdjustmentProvider (bản cũ) chưa có:
//
//  1) Chống race-condition: nếu người dùng đổi filter liên tục
//     (vd kéo date picker nhanh, đổi năm/tháng liên tiếp), nhiều lệnh
//     load() có thể chạy song song. Nếu không kiểm soát, response của
//     request CŨ trả về SAU request MỚI có thể ghi đè dữ liệu mới hơn.
//     -> Dùng _requestId tăng dần, chỉ áp dụng kết quả của request mới nhất.
//
//  2) Search client-side: BudgetPlan/BudgetPlanAdjustment API hiện KHÔNG
//     hỗ trợ search hay phân trang phía server (khác PaymentListProvider,
//     có endpoint hỗ trợ search + pageIndex/pageSize thật sự). Vì dữ liệu
//     trả về đã là toàn bộ danh sách theo khoảng lọc (date range / year-month),
//     ta lọc ngay trên client, không cần gọi lại API mỗi khi gõ search.
//
// Subclass chỉ cần cung cấp:
//   - fetchItems(): gọi repository tương ứng, trả về List<T>
//   - matchesSearch(item, query): quy tắc lọc theo từ khoá tìm kiếm

import 'package:flutter/foundation.dart';

abstract class FollowingListProviderBase<T> extends ChangeNotifier {
  List<T> _items = [];
  bool _loading = false;
  String? _error;
  String _search = '';

  // Đánh số thứ tự request để phát hiện + bỏ qua response của request cũ.
  int _requestId = 0;

  /// Toàn bộ dữ liệu tải về (chưa lọc theo search), dùng khi cần tổng hợp
  /// trên toàn bộ tập dữ liệu đang theo bộ lọc hiện tại (vd tổng tiền).
  List<T> get rawItems => _items;

  bool get loading => _loading;
  String? get error => _error;
  String get search => _search;

  /// Danh sách đã áp dụng search (client-side).
  List<T> get items {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items.where((e) => matchesSearch(e, q)).toList();
  }

  /// Subclass override: gọi repository phù hợp với bộ lọc hiện tại của nó.
  @protected
  Future<List<T>> fetchItems();

  /// Subclass override: trả về true nếu [item] khớp từ khoá [query]
  /// (query đã được lowercase + trim sẵn).
  @protected
  bool matchesSearch(T item, String query);

  void setSearch(String value) {
    _search = value;
    notifyListeners(); // chỉ lọc lại danh sách đang có, không cần load() lại
  }

  Future<void> load() async {
    final myRequestId = ++_requestId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await fetchItems();
      if (myRequestId != _requestId) return; // có request mới hơn -> bỏ qua
      _items = result;
    } catch (e) {
      if (myRequestId != _requestId) return;
      _error = e.toString();
    } finally {
      if (myRequestId == _requestId) {
        _loading = false;
        notifyListeners();
      }
    }
  }
}
