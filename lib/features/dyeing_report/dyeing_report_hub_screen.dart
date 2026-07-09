// lib/features/dyeing_report/dyeing_report_hub_screen.dart
//
// Hub liệt kê toàn bộ report của module nhuộm (dyeing).
// Danh sách report lấy từ ReportRegistry (config-driven) — thêm report
// mới không cần đụng vào file này, chỉ cần sửa report_registry.dart.

import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '_shared/report_entry.dart';
import '_shared/report_registry.dart';

class DyeingReportHubScreen extends StatelessWidget {
  static const Color color = Color(0xFF2563EB);

  const DyeingReportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = ReportRegistry.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(context),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, i) => _buildCard(context, items[i]),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ReportEntry item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: item.builder),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(item.desc,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 201, 199, 199),
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ── AppBar — cùng style với PaymentListScreen bên expense ──────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.dyeingReportHubTitle,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ],
    );
  }
}
