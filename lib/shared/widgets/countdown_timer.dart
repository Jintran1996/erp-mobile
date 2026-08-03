import 'dart:async';
import 'package:flutter/material.dart';

/// Widget đếm ngược hạn duyệt — dùng chung cho mọi loại phiếu expense
class CountdownTimer extends StatefulWidget {
  final String dueAt;
  final String overdueLabel;

  /// THÊM THUỘC TÍNH: hiển thị dạng nhỏ gọn không nền để nhét vào AppBar
  final bool isMini;

  const CountdownTimer({
    super.key,
    required this.dueAt,
    this.overdueLabel = '! Quá hạn duyệt',
    this.isMini = false, // Mặc định vẫn là dạng khối hộp nguyên bản
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() {
    final due = DateTime.tryParse(widget.dueAt) ?? DateTime.now();
    _remaining = due.difference(DateTime.now());

    _timer?.cancel(); // Hủy timer cũ nếu có trước khi tạo mới
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void didUpdateWidget(CountdownTimer old) {
    super.didUpdateWidget(old);
    if (old.dueAt != widget.dueAt) {
      _initTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOver = _remaining.isNegative;
    final abs = _remaining.abs();

    // Tính toán chuỗi hiển thị thời gian
    final h = abs.inHours.toString().padLeft(2, '0');
    final m = (abs.inMinutes % 60).toString().padLeft(2, '0');
    final s = (abs.inSeconds % 60).toString().padLeft(2, '0');
    final String timeStr = isOver ? widget.overdueLabel : '$h:$m:$s';

    // --- XỬ LÝ CHẾ ĐỘ MINI CHO APPBAR ---
    if (widget.isMini) {
      // Khi quá hạn: dùng màu đỏ nhạt phối chữ đỏ đậm để không bị chói trên nền xanh
      final textColor =
          isOver ? const Color(0xFFFCA5A5) : Colors.amber.shade300;
      final iconData = isOver
          ? Icons.report_problem_rounded
          : Icons.access_time_filled_rounded;

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            timeStr,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      );
    }

    // --- GIỮ NGUYÊN CHẾ ĐỘ KHỐI HỘP NÊN ĐẬM CŨ CỦA BẠN ---
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isOver ? const Color(0xFFDC2626) : const Color(0xFFD97706),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        timeStr,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
