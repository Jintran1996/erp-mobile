// lib/screens/notification_screen.dart
//
// Vị trí : lib/screens/    ← Screen toàn cục
// Dùng   : NotificationProvider (list + markRead + markAllRead)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../core/models/notification_model.dart';
import '../features/_shared/app_mini_base.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider()..loadList(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<NotificationProvider>();

    return AppMiniBase(
      title: 'Thông báo',
      color: const Color(0xFF2563EB),
      // Nút "Đọc tất cả" ở AppBar
      actions: p.items.any((n) => !n.isRead)
          ? [
              TextButton(
                onPressed: () =>
                    context.read<NotificationProvider>().markAllRead(),
                child: const Text('Đọc tất cả',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ]
          : null,
      child: p.loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : p.error != null
              ? _buildError(context, p)
              : p.items.isEmpty
                  ? _buildEmpty()
                  : _buildList(context, p),
    );
  }

  Widget _buildError(BuildContext context, NotificationProvider p) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
        const SizedBox(height: 12),
        Text(p.error!, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: p.loadList,
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ));
  }

  Widget _buildEmpty() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_none_outlined,
            size: 56, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text('Không có thông báo',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
      ],
    ));
  }

  Widget _buildList(BuildContext context, NotificationProvider p) {
    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: p.loadList,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: p.items.length,
        itemBuilder: (context, i) => _NotificationCard(item: p.items[i]),
      ),
    );
  }
}

// ── Card từng thông báo ───────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<NotificationProvider>().markRead(item.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: item.isRead
              ? Border.all(color: Colors.grey.shade100)
              : Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          // Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.isRead
                  ? Colors.grey.shade100
                  : const Color(0xFF2563EB).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: item.isRead ? Colors.grey : const Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Nội dung
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (item.message != null) ...[
                const SizedBox(height: 3),
                Text(
                  item.message!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (item.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatTime(item.createdAt!),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ],
          )),
          // Dot chưa đọc
          if (!item.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
            ),
        ]),
      ),
    );
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
