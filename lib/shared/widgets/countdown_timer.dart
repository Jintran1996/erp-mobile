import 'dart:async';
import 'package:flutter/material.dart';

/// Widget đếm ngược hạn duyệt — dùng chung cho mọi loại phiếu expense
/// (payment_detail, advance_detail...).
///
/// Tự tính thời gian còn lại từ `dueAt` khi load lên, sau đó tự trừ
/// từng giây bằng Timer. Khi quá hạn, đổi sang hiển thị cảnh báo đỏ.
///
/// ```dart
/// CountdownTimer(dueAt: step['dueAt'].toString())
/// ```
class CountdownTimer extends StatefulWidget {
  final String dueAt;

  /// Nhãn hiển thị khi đã quá hạn. Mặc định "! Quá hạn duyệt".
  final String overdueLabel;

  const CountdownTimer({
    super.key,
    required this.dueAt,
    this.overdueLabel = '! Quá hạn duyệt',
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
    final due = DateTime.tryParse(widget.dueAt) ?? DateTime.now();
    _remaining = due.difference(DateTime.now());

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void didUpdateWidget(CountdownTimer old) {
    super.didUpdateWidget(old);
    // Nếu dueAt đổi (vd sau khi reload phiếu), tính lại từ đầu.
    if (old.dueAt != widget.dueAt) {
      final due = DateTime.tryParse(widget.dueAt) ?? DateTime.now();
      _remaining = due.difference(DateTime.now());
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
    final h = abs.inHours.toString().padLeft(2, '0');
    final m = (abs.inMinutes % 60).toString().padLeft(2, '0');
    final s = (abs.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isOver ? const Color(0xFFDC2626) : const Color(0xFFD97706),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOver ? widget.overdueLabel : '$h:$m:$s',
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
