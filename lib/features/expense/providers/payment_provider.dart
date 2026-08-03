// lib/providers/payment_provider.dart

import 'package:flutter/foundation.dart';
import 'approval_detail_provider.dart';
import '../data/models/payment_model.dart';
import '../data/models/advance_model.dart';
import '../data/models/advance_settlement_model.dart';
import '../data/repositories/payment_repository.dart';

enum PaymentTab { following, pendingApproval }

enum ExpenseType { payment, advance, advanceSettlement }

// ── PaymentListProvider ───────────────────────────────────────────────
class PaymentListProvider extends ChangeNotifier {
  final _payRepo = PaymentRepository.instance;
  final _advRepo = AdvanceRepository.instance;
  final _setRepo = SettlementRepository.instance;
  static const int _pageSize = 20;

  PaymentTab _topTab = PaymentTab.following;
  ExpenseType _bottomTab = ExpenseType.payment;
  int? _statusFilter;
  String _search = '';
  List<dynamic> _items = [];
  int _totalCount = 0;
  int _page = 1;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  PaymentTab get topTab => _topTab;
  ExpenseType get bottomTab => _bottomTab;
  int? get statusFilter => _statusFilter;
  String get search => _search;
  List<dynamic> get items => _items;
  int get total => _totalCount;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _items.length < _totalCount;
  String? get error => _error;

  static const _endpoints = {
    PaymentTab.following: {
      ExpenseType.payment: '/api/expense-payments/following',
      ExpenseType.advance: '/api/advance-payments/following',
      ExpenseType.advanceSettlement: '/api/advance-settlements/following',
    },
    PaymentTab.pendingApproval: {
      ExpenseType.payment: '/api/expense-payments/my-pending-approvals',
      ExpenseType.advance: '/api/advance-payments/my-pending-approvals',
      ExpenseType.advanceSettlement:
          '/api/advance-settlements/my-pending-approvals',
    },
  };

  String get _currentEndpoint => _endpoints[_topTab]![_bottomTab]!;
  bool get _isAdvance => _bottomTab == ExpenseType.advance;
  bool get _isSettlement => _bottomTab == ExpenseType.advanceSettlement;

  void setTopTab(PaymentTab tab) {
    if (_topTab == tab) return;
    _topTab = tab;
    _statusFilter = null;
    loadFirstPage();
  }

  void setBottomTab(ExpenseType type) {
    if (_bottomTab == type) return;
    _bottomTab = type;
    _statusFilter = null;
    loadFirstPage();
  }

  void setStatusFilter(int? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    loadFirstPage();
  }

  void setSearch(String value) {
    _search = value;
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    _loading = true;
    _error = null;
    _page = 1;
    _items = [];
    notifyListeners();
    try {
      final result = await _fetchPage(page: 1);
      _items = result.items;
      _totalCount = result.totalCount;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || !hasMore || _loading) return;
    _loadingMore = true;
    notifyListeners();
    try {
      final nextPage = _page + 1;
      final result = await _fetchPage(page: nextPage);
      _page = nextPage;
      _items = [..._items, ...result.items];
      _totalCount = result.totalCount;
    } catch (_) {
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  // Khi search: dùng pageSize lớn hơn để lấy nhiều kết quả từ backend
  // Backend filter trong toàn bộ data, trả về theo pageSize
  int get _effectivePageSize => _search.isNotEmpty ? 100 : _pageSize;

  Future<PagedResult<dynamic>> _fetchPage({required int page}) async {
    final size = _effectivePageSize;
    final s = _search.isNotEmpty ? _search : null;
    if (_isAdvance) {
      return _advRepo.getList(
          endpoint: _currentEndpoint,
          page: page,
          pageSize: size,
          status: _statusFilter,
          search: s);
    }

    if (_isSettlement) {
      return _setRepo.getList(
          endpoint: _currentEndpoint,
          page: page,
          pageSize: size,
          status: _statusFilter,
          search: s);
    }
    return _payRepo.getList(
        endpoint: _currentEndpoint,
        page: page,
        pageSize: size,
        status: _statusFilter,
        search: s);
  }
}

class PaymentDetailProvider extends ApprovalDetailProvider<PaymentDetail> {
  PaymentDetailProvider()
      : super(
          fetchDetail: PaymentRepository.instance.getDetail,
          approve: PaymentRepository.instance.approve,
          reject: PaymentRepository.instance.reject,
        );
}

class AdvanceDetailProvider extends ApprovalDetailProvider<AdvanceDetail> {
  AdvanceDetailProvider()
      : super(
          fetchDetail: AdvanceRepository.instance.getDetail,
          approve: AdvanceRepository.instance.approve,
          reject: AdvanceRepository.instance.reject,
        );
}

class SettlementDetailProvider
    extends ApprovalDetailProvider<SettlementDetail> {
  SettlementDetailProvider()
      : super(
          fetchDetail: SettlementRepository.instance.getDetail,
          approve: SettlementRepository.instance.approve,
          reject: SettlementRepository.instance.reject,
        );
}
