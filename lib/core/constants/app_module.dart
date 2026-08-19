import 'package:flutter/material.dart';

enum AppModule {
  account('account'),
  expense('expense'),
  finance('finance'),
  core('core'),
  proposal('proposal');

  const AppModule(this.value);

  final String value;
}

enum AppColor {
  // 1. Khai báo các tên màu và truyền giá trị Color tương ứng vào
  headerTextFinance(Color.fromARGB(255, 58, 58, 58)),
  headerBackgroudFinance(Color.fromARGB(255, 255, 255, 255)),
  backgroundColor(Color.fromARGB(255, 255, 255, 255)),
  buttonHomeColor(Color.fromARGB(255, 17, 0, 255)),
  expense(Color(0xFFEF4444)),
  finance(Color(0xFF10B981)),
  core(Color(0xFF6366F1)),
  proposal(Color(0xFFF59E0B));

  // 2. Định nghĩa biến đại diện là kiểu Color (Thay vì String)
  final Color value;

  // 3. Constructor để khởi tạo
  const AppColor(this.value);
}
