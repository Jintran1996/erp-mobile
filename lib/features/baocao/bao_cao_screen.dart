import 'package:flutter/material.dart';
import '../_shared/app_mini_base.dart';

class BaoCaoScreen extends StatelessWidget {
  const BaoCaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppMiniBase(
      title: 'Báo cáo',
      color: const Color(0xFF2563EB),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan hôm nay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard('Nhân viên',   '124', Icons.people,         Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Đi làm',      '98',  Icons.check_circle,   Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard('Vắng mặt',    '5',   Icons.cancel,         Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('Đi trễ',      '21',  Icons.access_time,    Colors.orange)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Chấm công tuần này',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _barRow('T2', 0.95),
            _barRow('T3', 0.88),
            _barRow('T4', 0.92),
            _barRow('T5', 0.79),
            _barRow('T6', 0.85),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  )),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barRow(String day, double pct) {
    final color = pct >= 0.9
        ? Colors.green
        : pct >= 0.8
            ? Colors.orange
            : Colors.red;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(day, style: const TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(pct * 100).round()}%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
