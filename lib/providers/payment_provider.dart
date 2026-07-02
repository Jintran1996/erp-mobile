// lib/providers/payment_provider.dart

import 'package:flutter/foundation.dart';
import '../core/models/payment_model.dart';
import '../core/models/advance_model.dart';
import '../core/models/advance_settlement_model.dart'; // ✅ Fix #2: cùng path với repository
import '../repositories/payment_repository.dart';

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

  Future<PagedResult<dynamic>> _fetchPage({required int page}) async {
    final params = (String ep) => (int p) async {
          if (_isAdvance)
            return _advRepo.getList(
                endpoint: ep,
                page: p,
                pageSize: _pageSize,
                status: _statusFilter,
                search: _search.isNotEmpty ? _search : null);
          if (_isSettlement)
            return _setRepo.getList(
                endpoint: ep,
                page: p,
                pageSize: _pageSize,
                status: _statusFilter,
                search: _search.isNotEmpty ? _search : null);
          return _payRepo.getList(
              endpoint: ep,
              page: p,
              pageSize: _pageSize,
              status: _statusFilter,
              search: _search.isNotEmpty ? _search : null);
        };
    return params(_currentEndpoint)(page);
  }
}

// ── PaymentDetailProvider ─────────────────────────────────────────────
class PaymentDetailProvider extends ChangeNotifier {
  final _repo = PaymentRepository.instance;
  PaymentDetail? _detail;
  bool _loading = false;
  String? _error;
  bool _acting = false;

  PaymentDetail? get detail => _detail;
  bool get loading => _loading;
  String? get error => _error;
  bool get acting => _acting;

  Future<void> load(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _detail = await _repo.getDetail(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> approve(String id) async {
    _acting = true;
    notifyListeners();
    try {
      await _repo.approve(id);
      await load(id);
      return true;
    } catch (e) {
      _acting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(String id, String reason) async {
    _acting = true;
    notifyListeners();
    try {
      await _repo.reject(id, reason);
      await load(id);
      return true;
    } catch (e) {
      _acting = false;
      notifyListeners();
      return false;
    }
  }
}

// ── AdvanceDetailProvider — Fix #3: thêm lại class bị thiếu ──────────
class AdvanceDetailProvider extends ChangeNotifier {
  final _repo = AdvanceRepository.instance;
  AdvanceDetail? _detail;
  bool _loading = false;
  String? _error;
  bool _acting = false;

  AdvanceDetail? get detail => _detail;
  bool get loading => _loading;
  String? get error => _error;
  bool get acting => _acting;

  Future<void> load(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _detail = await _repo.getDetail(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> approve(String id) async {
    _acting = true;
    notifyListeners();
    try {
      await _repo.approve(id);
      await load(id);
      return true;
    } catch (e) {
      _acting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(String id, String reason) async {
    _acting = true;
    notifyListeners();
    try {
      await _repo.reject(id, reason);
      await load(id);
      return true;
    } catch (e) {
      _acting = false;
      notifyListeners();
      return false;
    }
  }
}

// ── SettlementDetailProvider ──────────────────────────────────────────
class SettlementDetailProvider extends ChangeNotifier {
  final _repo = SettlementRepository.instance;
  SettlementDetail? _detail;
  bool _loading = false;
  String? _error;
  bool _acting = false;

  SettlementDetail? get detail => _detail;
  bool get loading => _loading;
  String? get error => _error;
  bool get acting => _acting;

  Future<void> load(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _detail = await _repo.getDetail(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> approve(String id) async {
    _acting = true;
    notifyListeners();
    try {
      await _repo.approve(id);
      await load(id);
      return true;
    } catch (e) {
      _acting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(String id, String reason) async {
    _acting = true;
    notifyListeners();
    try {
      await _repo.reject(id, reason);
      await load(id);
      return true;
    } catch (e) {
      _acting = false;
      notifyListeners();
      return false;
    }
  }
}
