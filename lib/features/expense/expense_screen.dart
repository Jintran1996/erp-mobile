// lib/features/expense/expense_screen.dart
//
// Entry point của AppMini Expense.
// Trước đây: ExpenseScreen → PaymentTab → PaymentListScreen(apiEndpoint)
// Hiện tại : ExpenseScreen → PaymentListScreen (tự quản lý tab + endpoint bên trong)
// PaymentTab không còn cần thiết nữa.

import 'package:flutter/material.dart';
import 'payment_list_screen.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaymentListScreen(
      title: 'Chi phí',
      color: Color(0xFF16A34A),
    );
  }
}
