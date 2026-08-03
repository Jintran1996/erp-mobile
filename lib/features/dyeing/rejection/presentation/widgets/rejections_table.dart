// lib/features/dyeing_report/rejection/presentation/widgets/rejections_table.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../data/rejection_model.dart';

class RejectionsTable extends StatelessWidget {
  final List<RejectionMonthData> rows;
  const RejectionsTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.##');
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
        columns: [
          DataColumn(label: Text(l10n.colMonth)),
          DataColumn(label: Text(l10n.colTotal), numeric: true),
          DataColumn(label: Text(l10n.colReprocess), numeric: true),
          DataColumn(label: Text(l10n.colReprocessPercent), numeric: true),
          DataColumn(label: Text(l10n.colDefect), numeric: true),
          DataColumn(label: Text(l10n.colDefectPercent), numeric: true),
        ],
        rows: rows.map((r) {
          final isWarning = r.tyLeDefect > 5;
          return DataRow(
            color: isWarning ? WidgetStateProperty.all(Colors.red.shade50) : null,
            cells: [
              DataCell(Text(r.monthLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(fmt.format(r.totalMet))),
              DataCell(Text(fmt.format(r.recycling))),
              DataCell(Text('${r.tyLeReprocess.toStringAsFixed(2)}%')),
              DataCell(Text(fmt.format(r.rejected))),
              DataCell(Text(
                '${r.tyLeDefect.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: isWarning ? Colors.red : null,
                  fontWeight: isWarning ? FontWeight.bold : null,
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}
