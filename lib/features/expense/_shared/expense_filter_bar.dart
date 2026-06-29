// lib/features/expense/_shared/expense_filter_bar.dart

import 'package:flutter/material.dart';
import 'expense_status.dart';

// ── Search box ────────────────────────────────────────────────────────
Widget expenseSearchBox({
  required TextEditingController controller,
  required ValueChanged<String> onChanged,
  required VoidCallback onClear,
  String hintText = 'Tìm mã phiếu, tên phiếu...',
}) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 13),
        prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  controller.clear();
                  onClear();
                })
            : null,
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

// ── Filter chips ──────────────────────────────────────────────────────
Widget expenseFilterChips({
  required List<StatusFilterItem> items,
  required int activeIndex,
  required Color color,
  required ValueChanged<int> onSelected,
}) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length, (i) {
          final active = activeIndex == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? color : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  items[i].label,
                  style: TextStyle(
                    fontSize: 13,
                    color: active ? Colors.white : Colors.grey.shade600,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}

// ── Result count ──────────────────────────────────────────────────────
// total: tổng số trên server (nếu có), count: số đang hiển thị
Widget expenseResultCount(int count, {int? total, String unit = 'phiếu'}) {
  final label =
      (total != null && total > count) ? '$count/$total $unit' : '$count $unit';
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Row(children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
    ]),
  );
}

// ── Empty state ───────────────────────────────────────────────────────
Widget expenseEmptyList({required bool isSearching}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          isSearching ? 'Không tìm thấy phiếu' : 'Không có dữ liệu',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
      ],
    ),
  );
}

// ── Error state ───────────────────────────────────────────────────────
Widget expenseErrorView({
  required String message,
  required VoidCallback onRetry,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
