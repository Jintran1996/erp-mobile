// lib/providers/payment_provider.dart
//
// Quản lý state cho màn hình Expense (Payment + Advance).
// Screen chỉ gọi provider.method() và watch state — không biết về API hay model.

import 'package:flutter/foundation.dart';
import '../core/models/payment_model.dart';
import '../core/models/advance_model.dart';
import '../repositories/payment_repository.dart';

// ── Enum endpoint theo tab ────────────────────────────────────────────
enum PaymentTab { following, pendingApproval }

enum ExpenseType { payment, advance, advanceSettlement }

// ── PaymentListProvider ───────────────────────────────────────────────
class PaymentListProvider extends ChangeNotifier {
  final _payRepo = PaymentRepository.instance;
  final _advRepo = AdvanceRepository.instance;

  static const int _pageSize = 20;

  // ── State ─────────────────────────────────────────────────────────
  PaymentTab _topTab = PaymentTab.following;
  ExpenseType _bottomTab = ExpenseType.payment;
  int? _statusFilter; // null = Tất cả
  String _search = '';

  List<dynamic> _items = [];
  int _totalCount = 0;
  int _page = 1;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────────
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

  // ── Endpoint theo tab ──────────────────────────────────────────────
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

  bool get _isAdvance =>
      _bottomTab == ExpenseType.advance ||
      _bottomTab == ExpenseType.advanceSettlement;

  // ── Actions ────────────────────────────────────────────────────────
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

  // ── Load first page ────────────────────────────────────────────────
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

  // ── Load more (infinite scroll) ────────────────────────────────────
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
      // loadMore fail → không hiện lỗi, chỉ dừng load
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<PagedResult<dynamic>> _fetchPage({required int page}) async {
    if (_isAdvance) {
      return _advRepo.getList(
        endpoint: _currentEndpoint,
        page: page,
        pageSize: _pageSize,
        status: _statusFilter,
        search: _search.isNotEmpty ? _search : null,
      );
    } else {
      return _payRepo.getList(
        endpoint: _currentEndpoint,
        page: page,
        pageSize: _pageSize,
        status: _statusFilter,
        search: _search.isNotEmpty ? _search : null,
      );
    }
  }
}

// ── PaymentDetailProvider ─────────────────────────────────────────────
class PaymentDetailProvider extends ChangeNotifier {
  final _payRepo = PaymentRepository.instance;

  PaymentDetail? _detail;
  bool _loading = false;
  String? _error;
  bool _acting = false; // đang duyệt/từ chối

  PaymentDetail? get detail => _detail;
  bool get loading => _loading;
  String? get error => _error;
  bool get acting => _acting;

  Future<void> load(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _detail = await _payRepo.getDetail(id);
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
      await _payRepo.approve(id);
      await load(id); // reload để cập nhật status
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
      await _payRepo.reject(id, reason);
      await load(id);
      return true;
    } catch (e) {
      _acting = false;
      notifyListeners();
      return false;
    }
  }
}

// ── AdvanceDetailProvider ─────────────────────────────────────────────
class AdvanceDetailProvider extends ChangeNotifier {
  final _advRepo = AdvanceRepository.instance;

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
      _detail = await _advRepo.getDetail(id);
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
      await _advRepo.approve(id);
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
      await _advRepo.reject(id, reason);
      await load(id);
      return true;
    } catch (e) {
      _acting = false;
      notifyListeners();
      return false;
    }
  }
}
