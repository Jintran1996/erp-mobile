// lib/features/dyeing_report/rejection/presentation/rejections_dashboard_screen.dart
//
// AppBar dùng chung style với PaymentListScreen:
//   backgroundColor: màu riêng của report, foregroundColor: trắng,
//   actions: [refresh -> reload dữ liệu, home -> Navigator.popUntil first]

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'rejections_provider.dart';
import 'widgets/rejections_filter_bar.dart';
import 'widgets/rejections_table.dart';
import 'widgets/rejections_line_chart_card.dart';

class RejectionDashboardPage extends StatelessWidget {
  final Color color;
  const RejectionDashboardPage(
      {super.key, this.color = const Color(0xFF2563EB)});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RejectionsProvider()..loadFirstPage(),
      child: _RejectionDashboardView(color: color),
    );
  }
}

class _RejectionDashboardView extends StatelessWidget {
  final Color color;
  const _RejectionDashboardView({required this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RejectionsProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(context, p),
      body: RefreshIndicator(
        onRefresh: p.loadFirstPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNote(l10n),
              const SizedBox(height: 12),
              RejectionsFilterBar(color: color),
              const SizedBox(height: 24),
              Text(l10n.rejectionsListChartLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              if (p.loading) const LinearProgressIndicator(),
              if (p.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child:
                      Text(p.error!, style: const TextStyle(color: Colors.red)),
                ),
              if (!p.loading && p.error == null) ...[
                const SizedBox(height: 12),
                RejectionsTable(rows: p.rows),
                const SizedBox(height: 24),
                _buildCharts(context, p),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar — cùng style với PaymentListScreen (có nút back tường minh) ──
  PreferredSizeWidget _buildAppBar(BuildContext context, RejectionsProvider p) {
    return AppBar(
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(AppLocalizations.of(context)!.reportRejectionsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: p.loadFirstPage),
        IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ],
    );
  }

  Widget _buildNote(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Text(
        l10n.rejectionsNote,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }

  Widget _buildCharts(BuildContext context, RejectionsProvider p) {
    return LayoutBuilder(builder: (context, constraints) {
      final l10n = AppLocalizations.of(context)!;
      final isNarrow = constraints.maxWidth < 700;
      final reprocessChart = RejectionsLineChartCard(
        title: l10n.rejectionsReprocessChartTitle(p.selectedDate.year),
        color: Colors.blue,
        values: p.rows.map((r) => r.tyLeReprocess).toList(),
        labels: p.rows.map((r) => r.monthLabel).toList(),
      );
      final defectChart = RejectionsLineChartCard(
        title: l10n.rejectionsDefectChartTitle(p.selectedDate.year),
        color: Colors.red,
        values: p.rows.map((r) => r.tyLeDefect).toList(),
        labels: p.rows.map((r) => r.monthLabel).toList(),
      );

      if (isNarrow) {
        return Column(children: [
          reprocessChart,
          const SizedBox(height: 24),
          defectChart
        ]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: reprocessChart),
          const SizedBox(width: 16),
          Expanded(child: defectChart),
        ],
      );
    });
  }
}
