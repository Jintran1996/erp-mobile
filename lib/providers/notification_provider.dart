// lib/providers/notification_provider.dart
//
// Vị trí : lib/providers/    ← Provider tầng toàn cục
// Nhiệm vụ: quản lý state thông báo — danh sách + unreadCount
// Dùng bởi: NotificationScreen, HomeScreen (badge)

import 'package:flutter/foundation.dart';
import '../core/models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final _repo = NotificationRepository.instance;

  // ── State ─────────────────────────────────────────────────────────
  List<NotificationModel> _items = [];
  int _unreadCount = 0;
  bool _loading = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────
  List<NotificationModel> get items => _items;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;
  String? get error => _error;
  // ── Load danh sách ────────────────────────────────────────────────
  Future<void> loadList() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _repo.getList();
      // Đếm lại từ list (tránh gọi thêm API)
      _unreadCount = _items.where((n) => !n.isRead).length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Load chỉ unreadCount (dùng ở HomeScreen badge) ────────────────
  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _repo.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  // ── Đánh dấu 1 thông báo đã đọc ─────────────────────────────────
  Future<void> markRead(String id) async {
    // Optimistic update — cập nhật UI trước, gọi API sau
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    if (_items[idx].isRead) return; // đã đọc rồi, không làm gì

    _items[idx] = _items[idx].copyWith(isRead: true);
    if (_unreadCount > 0) _unreadCount--;
    notifyListeners();

    try {
      await _repo.markRead(id);
    } catch (_) {
      // Rollback nếu API fail
      _items[idx] = _items[idx].copyWith(isRead: false);
      _unreadCount++;
      notifyListeners();
    }
  }

  // ── Đánh dấu tất cả đã đọc ───────────────────────────────────────
  Future<void> markAllRead() async {
    // Optimistic update
    final prev = List<NotificationModel>.from(_items);
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _repo.markAllRead();
    } catch (_) {
      // Rollback
      _items = prev;
      _unreadCount = prev.where((n) => !n.isRead).length;
      notifyListeners();
    }
  }

  // ── Tăng count từ SignalR (HomeScreen gọi khi nhận realtime) ──────
  void onRealtimeNotification() {
    _unreadCount++;
    notifyListeners();
  }

  // ── Reset về 0 (khi user mở màn hình thông báo) ──────────────────
  void resetCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}
