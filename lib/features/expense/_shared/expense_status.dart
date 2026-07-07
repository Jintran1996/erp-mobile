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
  // ── Cơ bản ─────────────────────────────────────────────────────────
  0: StatusCfg('Nháp', Color(0xFFF1F5F9), Color(0xFF475569)),
  1: StatusCfg('Chờ duyệt', Color(0xFFFEF3C7), Color(0xFF92400E)),
  2: StatusCfg('Đã duyệt', Color(0xFFD1FAE5), Color(0xFF065F46)),
  3: StatusCfg('Từ chối', Color(0xFFFEE2E2), Color(0xFF991B1B)),
  4: StatusCfg('Đã hủy', Color(0xFFF3F4F6), Color(0xFF6B7280)),

  // ── Lệnh thanh toán ────────────────────────────────────────────────
  5: StatusCfg('Tạo lệnh 1 phần', Color(0xFFDBEAFE), Color(0xFF1D4ED8)),
  6: StatusCfg('Tạo lệnh đầy đủ', Color(0xFFD1FAE5), Color(0xFF065F46)),

  // ── Hoàn ứng ───────────────────────────────────────────────────────
  7: StatusCfg('Chờ hoàn ứng', Color(0xFFFEF3C7), Color(0xFF92400E)),
  8: StatusCfg('Hoàn ứng 1 phần', Color(0xFFEFF6FF), Color(0xFF1E40AF)),
  9: StatusCfg('Hoàn ứng đầy đủ', Color(0xFFDBEAFE), Color(0xFF1D4ED8)),
  10: StatusCfg('Đã hoàn thành', Color(0xFFD1FAE5), Color(0xFF065F46)),
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
  StatusFilterItem('Tạo lệnh đầy đủ', 6),
];
