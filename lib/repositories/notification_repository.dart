// lib/repositories/notification_repository.dart
//
// Vị trí : lib/repositories/    ← Repository tầng toàn cục
// Nhiệm vụ: gọi ApiClient → chuyển JSON thành NotificationModel
// Không biết gì về UI hay state

import '../services/api_client.dart';
import '../core/models/notification_model.dart';

class NotificationRepository {
  NotificationRepository._();
  static final NotificationRepository instance = NotificationRepository._();

  final _api = ApiClient.instance;

  // ── Danh sách thông báo ───────────────────────────────────────────
  Future<List<NotificationModel>> getList({
    bool unreadOnly = false,
    int page = 1,
    int pageSize = 30,
  }) async {
    final res = await _api.get('/api/notification', params: {
      'unreadOnly': unreadOnly,
      'page': page,
      'pageSize': pageSize,
    });

    // Backend trả data là List trực tiếp (không wrap trong items/totalCount)
    final raw = res['data'];
    final list = (raw is List ? raw : []);

    return list
        .map((j) => NotificationModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // ── Số thông báo chưa đọc ────────────────────────────────────────
  Future<int> getUnreadCount() async {
    final res = await _api.get('/api/notification/unread-count');
    return (res['data'] as int?) ?? 0;
  }

  // ── Đánh dấu đã đọc ──────────────────────────────────────────────
  Future<void> markRead(String id) async {
    await _api.post('/api/notification/$id/read');
  }

  // ── Đánh dấu tất cả đã đọc ───────────────────────────────────────
  Future<void> markAllRead() async {
    await _api.post('/api/notification/read-all');
  }
}
