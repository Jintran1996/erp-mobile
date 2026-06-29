import 'package:flutter/material.dart';

// ─── Template dùng chung cho mọi AppMini ───────────
class AppMiniBase extends StatelessWidget {
  final String        title;
  final Color         color;
  final Widget        child;
  final List<Widget>? actions;
  final Widget?       floatingActionButton;

  const AppMiniBase({
    super.key,
    required this.title,
    required this.color,
    required this.child,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: actions,
      ),
      backgroundColor: const Color(0xFFF1F5F9),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}

// ─── Màn hình "Đang phát triển" cho app chưa xây ───
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final Color  color;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppMiniBase(
      title: title,
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 72,
              color: color.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đang phát triển',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tính năng $title sẽ sớm ra mắt',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
