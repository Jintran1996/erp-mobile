// lib/widgets/notification_badge.dart
//
// Vị trí  : lib/widgets/           ← widget toàn cục
// Tách từ : home_screen.dart (Stack + Positioned trong _buildHeader)
//
// NotificationBadge — bọc bất kỳ widget nào với badge số đỏ góc trên phải.
//
// Cách dùng đơn giản nhất (icon chuông):
//   NotificationBadge(
//     count:   _unreadCount,
//     onTap:   () { ... },
//   )
//
// Hoặc bọc widget bất kỳ:
//   NotificationBadge(
//     count: _unreadCount,
//     onTap: () { ... },
//     child: const Icon(Icons.notifications_outlined),
//   )

import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  /// Số thông báo chưa đọc. Badge ẩn khi = 0.
  final int count;

  /// Callback khi nhấn vào icon/widget.
  final VoidCallback onTap;

  /// Widget con — mặc định là Icons.notifications_outlined.
  final Widget? child;

  /// Màu badge (mặc định đỏ).
  final Color badgeColor;

  /// Kích thước badge (mặc định 18).
  final double badgeSize;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.onTap,
    this.child,
    this.badgeColor = Colors.red,
    this.badgeSize = 18,
  });

  // Hiển thị tối đa "99+" để không tràn badge
  String get _label {
    if (count > 99) return '99+';
    if (count > 9) return '9+';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Widget chính (icon chuông hoặc custom)
        IconButton(
          icon: child ?? const Icon(Icons.notifications_outlined),
          onPressed: onTap,
          tooltip: count > 0 ? '$count thông báo chưa đọc' : 'Thông báo',
        ),

        // Badge — chỉ hiển thị khi count > 0
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: IgnorePointer(
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  // Viền trắng giúp badge nổi bật trên mọi nền
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    _label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: badgeSize * 0.55,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
