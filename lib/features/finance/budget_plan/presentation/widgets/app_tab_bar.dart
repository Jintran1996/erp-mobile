// lib/core/widgets/app_tab_bar.dart
//
// Thanh Tab dùng chung (Topbar), tách riêng khỏi AppBar để tái sử dụng
// được ở nhiều màn hình khác nhau.
//
// STYLE: dạng segmented control nền sáng — tab đang chọn có nền xanh nhạt
// "phát sáng" (glow rất mờ bằng boxShadow alpha thấp) + CHỮ MÀU XANH + gạch
// chân mảnh bên dưới (có thể tắt qua `underlineWidth: 0`).
//
// LƯU Ý VỀ CHIỀU CAO: TabBar cần tối thiểu ~36-40px để chứa chữ + indicator
// bo góc, không ép preferredSize xuống quá thấp kẻo tràn layout.

import 'package:flutter/material.dart';

class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.activeColor = const Color(0xFF2563EB),
    this.backgroundColor = Colors.white,
    this.height = 44,
    //this.underlineWidth = 2,
    this.elevated = false,
  });

  final TabController controller;
  final List<String> tabs;

  /// Màu chủ đạo khi tab được chọn — dùng cho CHỮ, nền glow nhạt và gạch chân.
  final Color activeColor;
  final Color backgroundColor;

  /// Chiều cao tổng của topbar (mặc định 44).
  final double height;

  /// Độ dày gạch chân xanh bên dưới tab đang chọn (nằm gọn trong pill).
  /// Set = 0 nếu muốn tắt gạch chân, chỉ giữ pill nền nhạt + chữ xanh.
  //final double underlineWidth;

  /// true = thêm bóng đổ + bo góc cho khung ngoài, dùng khi đặt AppTabBar
  /// "nổi" đè lên ranh giới giữa 2 vùng màu khác nhau (Positioned trong
  /// Stack) — xem budget_plan_screen.dart để biết cách dùng.
  final bool elevated;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      // Khung ngoài dạng segmented control: viền mờ + bo góc, giống ảnh mẫu
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs.map((t) => Tab(text: t)).toList(),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        // ✅ Chữ MÀU XANH khi được chọn (thay vì trắng như bản cũ)
        labelColor: activeColor,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        // ✅ Indicator: nền xanh NHẠT + glow rất mờ (alpha 0.05) + gạch
        // chân mảnh ở cạnh dưới (Border chỉ đặt `bottom` nên chỉ vẽ 1
        // đường mảnh dưới đáy pill, không bọc quanh 4 cạnh).
        indicator: BoxDecoration(
          color: activeColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 0.5,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashBorderRadius: BorderRadius.circular(4),
      ),
    );

    if (!elevated) {
      return Container(
        height: height,
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: content,
      );
    }

    // Chế độ "nổi" (floating): nền trắng + bo góc + bóng đổ rõ hơn để
    // tách biệt khỏi cả 2 vùng màu phía trên/dưới nó.
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: content,
    );
  }
}
