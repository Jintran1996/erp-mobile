import 'package:flutter/material.dart';

/// Các widget "chip" nhỏ dùng chung trong card và detail của
/// payment, advance, và mọi mini-app expense khác.

/// Ô thông tin có icon + nhãn + giá trị nổi bật, nền màu nhạt.
/// Dùng trong card list (vd: "Tổng tiền", "Hạn TT").
///
/// ```dart
/// infoChip(
///   icon: Icons.payments_outlined,
///   label: 'Tổng tiền',
///   value: '${formatMoney(amount)} ₫',
///   color: const Color(0xFF059669),
/// )
/// ```
Widget infoChip({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ]),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

/// Tag nhỏ bo tròn có icon + nhãn — dùng cho người duyệt, người tạo,
/// trạng thái phụ (vd: "Ngoại tệ"). Co giãn theo nội dung.
///
/// ```dart
/// tagChip(
///   icon: Icons.person_outline,
///   label: creatorName,
///   bg: const Color(0xFFF5F3FF),
///   fg: const Color(0xFF6D28D9),
/// )
/// ```
Widget tagChip({
  required IconData icon,
  required String label,
  required Color bg,
  required Color fg,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: fg),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style:
                TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

/// Badge trạng thái dạng pill — dùng chung với expense_status.dart.
/// Nhận sẵn bg/text từ StatusCfg, không cần biết status là gì.
///
/// ```dart
/// final cfg = getStatusCfg(item['status']);
/// statusBadge(label: cfg.label, bg: cfg.bg, fg: cfg.text)
/// ```
Widget statusBadge({
  required String label,
  required Color bg,
  required Color fg,
  double fontSize = 11,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10,
        color: fg,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// Avatar tròn dùng chữ cái đầu khi không có ảnh — màu theo theme.
///
/// ```dart
/// avatarCircle(name: 'Nguyễn Văn Hùng', radius: 16, color: widget.color)
/// ```
Widget avatarCircle({
  required String name,
  required double radius,
  required Color color,
}) {
  final parts = name.trim().split(' ');
  final initials = parts.length >= 2
      ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
      : (name.isNotEmpty ? name[0].toUpperCase() : '?');

  return CircleAvatar(
    radius: radius,
    backgroundColor: color.withValues(alpha: 0.12),
    child: Text(
      initials,
      style: TextStyle(
        fontSize: radius * 0.65,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );
}
