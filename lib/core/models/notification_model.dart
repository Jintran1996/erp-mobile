// lib/core/models/notification_model.dart
//
// Vị trí : lib/core/models/    ← Model tầng toàn cục
// Dùng cho: NotificationRepository, NotificationProvider, NotificationScreen

class NotificationModel {
  final String id;
  final String title;
  final String? message;
  final bool isRead;
  final String? createdAt;
  final String? type; // loại thông báo (nếu backend có)
  final String? referenceId; // id phiếu liên quan (nếu có)

  const NotificationModel({
    required this.id,
    required this.title,
    required this.isRead,
    this.message,
    this.createdAt,
    this.type,
    this.referenceId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) =>
      NotificationModel(
        id: j['id']?.toString() ?? '',
        title: j['title'] as String? ?? '',
        message: j['message'] as String?,
        isRead: j['isRead'] as bool? ?? false,
        createdAt: j['createdAt'] as String?,
        type: j['type'] as String?,
        referenceId: j['referenceId'] as String?,
      );

  // copyWith — cập nhật isRead mà không tạo object mới từ JSON
  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        type: type,
        referenceId: referenceId,
      );
}
