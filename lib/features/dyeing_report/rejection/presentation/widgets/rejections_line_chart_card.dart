// lib/features/dyeing_report/rejection/presentation/widgets/rejections_line_chart_card.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RejectionsLineChartCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<double> values;
  final List<String> labels;

  const RejectionsLineChartCard({
    super.key,
    required this.title,
    required this.color,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    // Guard dữ liệu toàn 0 / rỗng để tránh minY == maxY (chart suy biến).
    double maxY = 10.0;
    if (values.isNotEmpty) {
      final rawMax = values.reduce((a, b) => a > b ? a : b);
      maxY = rawMax > 0 ? (rawMax * 1.2).ceilToDouble() : 10.0;
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 18, height: 10, color: color.withValues(alpha: 0.3)),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: values.isEmpty
                  ? const Center(child: Text('Không có dữ liệu'))
                  : LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: maxY,
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(labels[i], style: const TextStyle(fontSize: 10)),
                                );
                              },
                              reservedSize: 28,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (value, meta) =>
                                  Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10)),
                            ),
                          ),
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) => spots.map((s) {
                              return LineTooltipItem(
                                '${labels[s.x.toInt()]}\n${s.y.toStringAsFixed(2)}%',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList(),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
                            ],
                            isCurved: true,
                            color: color,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.08)),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
