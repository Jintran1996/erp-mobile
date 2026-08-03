import 'package:flutter/material.dart';

class DynamicActionBar extends StatelessWidget {
  final String primaryText; // Chữ hiển thị nút chính (ví dụ: Xem xét, Duyệt)
  final String secondaryText; // Chữ hiển thị nút phụ (ví dụ: Từ chối, Trả lại)
  final IconData primaryIcon; // Icon nút chính
  final IconData secondaryIcon; // Icon nút phụ
  final Color primaryColor; // Màu chủ đạo nút chính (mặc định Xanh Emerald)
  final Color secondaryColor; // Màu chủ đạo nút phụ (mặc định Đỏ)
  final bool isLoading; // Trạng thái chờ xử lý (acting)
  final VoidCallback? onPrimaryPressed; // Sự kiện khi bấm nút chính
  final VoidCallback? onSecondaryPressed; // Sự kiện khi bấm nút phụ

  const DynamicActionBar({
    super.key,
    required this.primaryText,
    this.secondaryText = 'Từ chối',
    this.primaryIcon = Icons.check_circle_outline_rounded,
    this.secondaryIcon = Icons.close_rounded,
    this.primaryColor = const Color(0xFF059669),
    this.secondaryColor = const Color(0xFFDC2626),
    required this.isLoading,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          16, 12, 16, 24), // Chừa khoảng trống chống tràn cằm máy
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, -4), // Đổ bóng mờ nhẹ ngược lên trên
          ),
        ],
      ),
      child: Row(
        children: [
          // --- NÚT PHỤ (BÊN TRÁI) ---
          Expanded(
            flex: 4,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : onSecondaryPressed,
              icon: Icon(secondaryIcon, size: 18),
              label: Text(
                secondaryText,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: secondaryColor,
                side: BorderSide(
                    color: secondaryColor.withValues(alpha: 0.1), width: 1.5),
                backgroundColor: secondaryColor.withValues(alpha: 0.05),
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // --- NÚT CHÍNH (BÊN PHẢI) ---
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  if (!isLoading && onPrimaryPressed != null)
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onPrimaryPressed,
                icon: isLoading
                    ? const SizedBox.shrink()
                    : Icon(primaryIcon, size: 18),
                label: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        primaryText,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 46),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
