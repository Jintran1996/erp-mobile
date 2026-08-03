// lib/core/providers/approval_detail_provider.dart
//
// Provider generic dùng chung cho mọi màn hình "chi tiết + duyệt/từ chối":
// PaymentDetail, AdvanceDetail, SettlementDetail... đều có cùng 1 khuôn:
//   load(id) -> hiển thị chi tiết
//   approve(id, workflowInstanceId) -> gọi API duyệt rồi load lại
//   reject(id, workflowInstanceId, reason) -> gọi API từ chối rồi load lại
//
// Thay vì copy-paste 3 lần (như PaymentDetailProvider / AdvanceDetailProvider /
// SettlementDetailProvider cũ), ta viết 1 lần và chỉ khác nhau ở phần
// "inject" 3 hàm gọi API tương ứng.
//
// Đồng thời có sẵn cơ chế chống race-condition: nếu người dùng gọi load()
// nhiều lần liên tiếp (đổi id nhanh, bấm reload nhiều lần...), chỉ kết quả
// của lần gọi MỚI NHẤT mới được áp dụng vào state.

import 'package:flutter/foundation.dart';

class ApprovalDetailProvider<T> extends ChangeNotifier {
  final Future<T> Function(String id) _fetchDetail;
  final Future<void> Function(String workflowInstanceId) _approveFn;
  final Future<void> Function(String workflowInstanceId, String reason)
      _rejectFn;

  ApprovalDetailProvider({
    required Future<T> Function(String id) fetchDetail,
    required Future<void> Function(String workflowInstanceId) approve,
    required Future<void> Function(String workflowInstanceId, String reason)
        reject,
  })  : _fetchDetail = fetchDetail,
        _approveFn = approve,
        _rejectFn = reject;

  // ── State ─────────────────────────────────────────────────────────
  T? _detail;
  bool _loading = false;
  String? _error;
  bool _acting = false;
  String? _actionError;

  // Đánh số thứ tự request để phát hiện request cũ trả về sau request mới.
  int _requestId = 0;

  T? get detail => _detail;
  bool get loading => _loading;
  String? get error => _error;
  bool get acting => _acting;
  // Lỗi riêng khi approve/reject thất bại (trước đây bị "nuốt" mất, không set _error)
  String? get actionError => _actionError;

  Future<void> load(String id) async {
    final myRequestId = ++_requestId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _fetchDetail(id);
      if (myRequestId != _requestId) return; // đã có request mới hơn -> bỏ qua
      _detail = result;
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

  Future<bool> approve(String id, String workflowInstanceId) async {
    _acting = true;
    _actionError = null;
    notifyListeners();
    try {
      await _approveFn(workflowInstanceId);
      await load(id);
      return true;
    } catch (e) {
      _actionError = e.toString();
      _acting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(
      String id, String workflowInstanceId, String reason) async {
    _acting = true;
    _actionError = null;
    notifyListeners();
    try {
      await _rejectFn(workflowInstanceId, reason);
      await load(id);
      return true;
    } catch (e) {
      _actionError = e.toString();
      _acting = false;
      notifyListeners();
      return false;
    }
  }
}
