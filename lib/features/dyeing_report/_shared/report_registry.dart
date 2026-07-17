// lib/features/dyeing_report/_shared/report_registry.dart
//
// Danh sách toàn bộ report của module dyeing_report.
// Muốn thêm report thứ 11, 12... chỉ cần thêm 1 ReportEntry ở đây,
// KHÔNG cần sửa DyeingReportHubScreen.

import 'package:flutter/material.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../rejection/presentation/rejections_dashboard_screen.dart';
import 'placeholder_report_screen.dart';
import 'report_entry.dart';

class ReportRegistry {
  static List<ReportEntry> build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      ReportEntry(
        title: l10n.reportRejectionsTitle,
        desc: l10n.reportRejectionsDesc,
        icon: Icons.donut_large_outlined,
        color: const Color(0xFF2563EB),
        builder: (_) => const RejectionDashboardPage(color: Color(0xFF2563EB)),
      ),
      ReportEntry(
        title: l10n.reportProductionTitle,
        desc: l10n.reportProductionDesc,
        icon: Icons.factory_outlined,
        color: const Color(0xFF059669),
        builder: (_) =>
            PlaceholderReportScreen(title: l10n.reportProductionTitle),
      ),
      ReportEntry(
        title: l10n.reportInventoryTitle,
        desc: l10n.reportInventoryDesc,
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFFD97706),
        builder: (_) =>
            PlaceholderReportScreen(title: l10n.reportInventoryTitle),
      ),
      ReportEntry(
        title: l10n.reportQualityTitle,
        desc: l10n.reportQualityDesc,
        icon: Icons.fact_check_outlined,
        color: const Color(0xFFDC2626),
        builder: (_) => PlaceholderReportScreen(title: l10n.reportQualityTitle),
      ),
      // TODO: thêm report mới ở đây, chỉ cần thêm 1 ReportEntry
    ];
  }
}
