import 'package:flutter/material.dart';

/// Cấu hình hiển thị cho 1 trạng thái: nhãn + màu nền + màu chữ.
/// Dùng chung cho mọi loại phiếu expense (thanh toán, tạm ứng, TT tạm ứng...).
class StatusCfg {
  final String label;
  final Color bg;
  final Color text;
  const StatusCfg(this.label, this.bg, this.text);
}

/// Map trạng thái dùng chung cho TOÀN BỘ module expense.
///
/// Áp dụng cho: payment_list/detail, advance_list/detail,
/// và bất kỳ mini-app expense nào thêm sau này.
///
/// status 0-5 đã xác nhận theo nghiệp vụ chung.
/// status 6, 7 hiện chỉ xuất hiện trong dữ liệu Tạm ứng —
/// TODO: hỏi backend ý nghĩa chính xác rồi cập nhật label bên dưới.
const Map<int, StatusCfg> expenseStatusMap = {
  0: StatusCfg('Nháp', Color(0xFFF1F5F9), Color(0xFF64748B)),
  1: StatusCfg('Chờ duyệt', Color(0xFFFEF3C7), Color(0xFFB45309)),
  2: StatusCfg('Đã duyệt', Color(0xFFD1FAE5), Color(0xFF065F46)),
  3: StatusCfg('Từ chối', Color(0xFFFEE2E2), Color(0xFF991B1B)),
  4: StatusCfg('Đã chi', Color(0xFFEDE9FE), Color(0xFF5B21B6)),
  5: StatusCfg('Đã hủy', Color(0xFFF1F5F9), Color(0xFF64748B)),
  6: StatusCfg('Trạng thái 6', Color(0xFFDBEAFE),
      Color(0xFF1E40AF)), // TODO: chờ xác nhận backend
  7: StatusCfg('Trạng thái 7', Color(0xFFFCE7F3),
      Color(0xFF9D174D)), // TODO: chờ xác nhận backend
};

/// Lấy cấu hình trạng thái an toàn — fallback về "Nháp" nếu status lạ.
StatusCfg getStatusCfg(int? status) =>
    expenseStatusMap[status ?? 0] ?? expenseStatusMap[0]!;

/// Item cho danh sách filter chips (Tất cả / Chờ duyệt / Đã duyệt / Từ chối...).
/// status = null nghĩa là "Tất cả" — không gửi param Status lên API.
class StatusFilterItem {
  final String label;
  final int? status;
  const StatusFilterItem(this.label, this.status);
}

/// Bộ filter mặc định dùng chung cho hầu hết list screen.
/// Có thể override riêng nếu 1 mini-app cần filter khác (vd thêm "Đã chi").
const List<StatusFilterItem> defaultStatusFilters = [
  StatusFilterItem('Tất cả', null),
  StatusFilterItem('Chờ duyệt', 1),
  StatusFilterItem('Đã duyệt', 2),
  StatusFilterItem('Từ chối', 3),
];
