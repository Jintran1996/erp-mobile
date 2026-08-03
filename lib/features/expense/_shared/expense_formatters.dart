/// Các hàm format dùng chung cho toàn bộ module expense
/// (payment, advance, và mọi mini-app expense thêm sau này).
///
/// Tách riêng để: payment_list, advance_list, payment_detail,
/// advance_detail... không phải tự viết lại các hàm này mỗi file.
library;

/// Format số tiền có dấu chấm ngăn cách hàng nghìn.
/// Ví dụ: 1296000 → "1.296.000"
///
/// Nhận dynamic vì dữ liệu JSON có thể trả về int, double, hoặc String.
String formatMoney(dynamic value) {
  if (value == null) return '0';
  final amount = (value is num)
      ? value.toInt()
      : (double.tryParse(value.toString()) ?? 0).toInt();
  final isNegative = amount < 0;
  final s = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return isNegative ? '-${buf.toString()}' : buf.toString();
}

/// Format ngày dạng dd/MM/yyyy từ chuỗi ISO 8601 backend trả về.
/// Ví dụ: "2026-06-23T17:00:00" → "23/06/2026"
String formatDate(dynamic value) {
  if (value == null) return '—';
  final s = value.toString();
  if (s.length >= 10) {
    return '${s.substring(8, 10)}/${s.substring(5, 7)}/${s.substring(0, 4)}';
  }
  return s;
}

/// Format giờ + ngày dạng "HH:mm  dd/MM/yyyy".
/// Ví dụ: "2026-06-17T13:08:59" → "13:08  17/06/2026"
String formatDateTime(dynamic value) {
  if (value == null) return '—';
  final s = value.toString();
  if (s.length >= 16) {
    final time = s.substring(11, 16);
    return '$time  ${formatDate(s)}';
  }
  return s;
}

/// Lấy chữ cái viết tắt từ họ tên, dùng cho avatar khi không có ảnh.
/// Ví dụ: "Nguyễn Văn Hùng" → "NH"
String initialsFromName(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  return parts.first[0].toUpperCase();
}
