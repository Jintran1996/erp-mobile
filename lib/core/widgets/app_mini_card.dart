// lib/widgets/app_mini_card.dart
//
// Vị trí  : lib/widgets/           ← widget toàn cục, HomeScreen dùng
// Chứa    : AppMiniItem (data class) + AppMiniCard (widget)
// Tách từ : home_screen.dart (_buildCard + class AppMiniItem)
//
// AppMiniItem  — data class mô tả 1 ô trong lưới AppMini.
// AppMiniCard  — widget hiển thị 1 ô đó (icon + tên + shadow).
//
// Cách dùng:
//   AppMiniCard(
//     item:  AppMiniItem(name: 'Expense', icon: Icons.attach_money,
//                        color: Color(0xFF16A34A), screen: ExpenseScreen()),
//     onTap: () => Navigator.push(context, ...),
//   )

import 'package:flutter/material.dart';

// ── Data class ────────────────────────────────────────────────────────
// Không phải Model theo MSRPSW — đây là cấu hình UI thuần,
// không map từ JSON, nên đặt ở widgets/ thay vì core/models/.
class AppMiniItem {
  final String name;
  final IconData icon;
  final Color color;
  final Widget screen;

  const AppMiniItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

// ── Widget ────────────────────────────────────────────────────────────
class AppMiniCard extends StatelessWidget {
  final AppMiniItem item;
  final VoidCallback onTap;

  const AppMiniCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 26),
            ),
            const SizedBox(height: 8),
            // Tên app
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
