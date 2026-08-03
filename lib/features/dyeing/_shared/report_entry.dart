// lib/features/dyeing_report/_shared/report_entry.dart
//
// Metadata cho 1 report trong hub. Thêm report mới = thêm 1 ReportEntry
// vào ReportRegistry, không cần sửa UI của hub.

import 'package:flutter/material.dart';

class ReportEntry {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final WidgetBuilder builder;

  const ReportEntry({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.builder,
  });
}
