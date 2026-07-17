// lib/features/dyeing_report/rejection/presentation/rejections_provider.dart
//
// Quản lý state: ngày chọn, thị trường chọn, dữ liệu, loading/error.
// Screen chỉ watch provider này, không tự gọi API hay giữ state riêng.

import 'package:flutter/material.dart';
import '../data/rejection_model.dart';
import '../data/rejection_api_service.dart';

class RejectionsProvider extends ChangeNotifier {
  final _api = RejectionApiService();

  static const List<Map<String, String>> markets = [
    {'code': 'ALL', 'label': 'All'},
    {'code': 'ND', 'label': 'ND'},
    {'code': 'XK', 'label': 'XK'},
    {'code': 'CN', 'label': 'CN'},
    // TODO: thêm các thị trường khác tại đây
  ];

  DateTime _selectedDate = DateTime.now();
  String _selectedMarket = 'ALL';
  bool _loading = false;
  String? _error;
  List<RejectionMonthData> _rows = [];

  DateTime get selectedDate => _selectedDate;
  String get selectedMarket => _selectedMarket;
  bool get loading => _loading;
  String? get error => _error;
  List<RejectionMonthData> get rows => _rows;

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setMarket(String market) {
    _selectedMarket = market;
    notifyListeners();
  }

  /// Tên đặt giống PaymentListProvider.loadFirstPage để dùng chung
  /// cho cả nút refresh trên AppBar lẫn RefreshIndicator (pull-to-refresh).
  Future<void> loadFirstPage() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result =
          await _api.fetch(date: _selectedDate, market: _selectedMarket);
      _rows = result.data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
