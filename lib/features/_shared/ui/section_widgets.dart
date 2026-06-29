import 'package:flutter/material.dart';
import 'chips.dart';

/// Các widget khối lớn dùng chung cho mọi màn hình chi tiết expense
/// (payment_detail, advance_detail, và mini-app expense thêm sau này).
///
/// Khác với expense_chips.dart (chip nhỏ, dùng cả trong card list lẫn
/// detail), file này chỉ chứa các khối bố cục riêng cho trang chi tiết:
/// section wrapper, hàng thông tin, hàng 3 ô tiền.

/// Khung card bo góc có icon + tiêu đề + nội dung bên trong.
/// Dùng cho mọi section trong trang chi tiết: "Thông tin chung",
/// "Thanh toán cho", "Luồng duyệt", "Hạng mục", "Tệp đính kèm"...
///
/// ```dart
/// expenseSection(
///   icon: Icons.info_outline,
///   title: 'Thông tin chung',s
///   color: widget.color,
///   child: Column(children: [...]),
/// )
/// ```
Widget expenseSection({
  required IconData icon,
  required String title,
  required Color color,
  required Widget child,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 16),
}) {
  return Container(
    margin: margin,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
        Divider(height: 1, color: Colors.grey.shade100),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: child,
        ),
      ],
    ),
  );
}

/// Hàng "nhãn — giá trị" dùng trong mọi section (Mã phiếu, Tạo bởi,
/// Hạn thanh toán...). Hỗ trợ nút copy và đổi màu giá trị.
///
/// ```dart
/// expenseInfoRow('Mã phiếu', d['subId'], copyable: true)
/// expenseInfoRow('Hạn thanh toán', formatDate(d['dueAt']),
///     valueColor: const Color(0xFFDC2626))
/// ```
Widget expenseInfoRow(
  String label,
  dynamic value, {
  bool copyable = false,
  Color? valueColor,
  VoidCallback? onCopy,
}) {
  final text = value?.toString() ?? '—';
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor)),
        ),
        if (copyable && text != '—' && onCopy != null)
          GestureDetector(
            onTap: onCopy,
            child: Icon(Icons.copy, size: 14, color: Colors.grey.shade400),
          ),
      ],
    ),
  );
}

/// Hàng nhiều ô tiền chia đều, có vạch ngăn cách giữa các ô.
/// Dùng cho "Tổng tiền TT / Đã tạo lệnh / Chưa tạo lệnh" hoặc tương tự.
///
/// ```dart
/// expenseMoneyRow([
///   MoneyCell('Tổng tiền', total, const Color(0xFF059669), large: true),
///   MoneyCell('Đã tạo lệnh', approved, const Color(0xFF2563EB)),
///   MoneyCell('Chưa tạo lệnh', remaining, const Color(0xFFDC2626)),
/// ])
/// ```
class MoneyCell {
  final String label;
  final String formattedValue; // đã format sẵn, vd "${formatMoney(v)} ₫"
  final Color color;
  final bool large;
  const MoneyCell(this.label, this.formattedValue, this.color,
      {this.large = false});
}

Widget expenseMoneyRow(List<MoneyCell> cells, {EdgeInsets? margin}) {
  final children = <Widget>[];
  for (var i = 0; i < cells.length; i++) {
    children.add(Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Text(cells[i].label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            cells[i].formattedValue,
            style: TextStyle(
              fontSize: cells[i].large ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: cells[i].color,
            ),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    ));
    if (i < cells.length - 1) {
      children
          .add(Container(width: 1, height: 40, color: Colors.grey.shade100));
    }
  }

  return Container(
    margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(children: children),
  );
}

/// Hàng hiển thị 1 người (người duyệt, người tạo, người theo dõi)
/// với avatar tròn + tên + chức vụ. Dùng trong "Luồng duyệt", "Người theo dõi".
///
/// ```dart
/// expensePersonRow(name: a['fullName'], position: a['position'], color: widget.color)
/// ```
Widget expensePersonRow({
  required String name,
  String? position,
  required Color color,
  String? avatarUrl,
  double avatarRadius = 14,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(children: [
      avatarUrl != null
          ? CircleAvatar(
              radius: avatarRadius, backgroundImage: NetworkImage(avatarUrl))
          : avatarCircle(name: name, radius: avatarRadius, color: color),
      const SizedBox(width: 6),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 12)),
            if (position != null && position.isNotEmpty)
              Text(position,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    ]),
  );
}

/// Trạng thái rỗng dùng chung — "Không có hạng mục", "Chưa có bình luận"...
Widget expenseEmptyHint(String message) {
  return Text(message,
      style: TextStyle(color: Colors.grey.shade400, fontSize: 13));
}
