// lib/features/dyeing_report/_shared/placeholder_report_screen.dart
//
// Màn hình tạm cho các report chưa build xong UI riêng.
// Xoá dần khi có screen thật thay thế (giống RejectionsDashboardPage).

import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';

class PlaceholderReportScreen extends StatelessWidget {
  final String title;
  const PlaceholderReportScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(l10n.reportPlaceholderBody(title),
            style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
