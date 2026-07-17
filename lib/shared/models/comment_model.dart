// lib/core/models/comment_model.dart

// ── User trong comment (field "user" — có avatar đầy đủ) ──────────────
// Khác CommentMention: user có avatarUrl, position; mention chỉ có userId+fullName
class CommentUser {
  final String id;
  final String fullName;
  final String? position;
  final String? avatarFileId;
  final String? avatarUrl;

  const CommentUser({
    required this.id,
    required this.fullName,
    this.position,
    this.avatarFileId,
    this.avatarUrl,
  });

  factory CommentUser.fromJson(Map<String, dynamic> j) => CommentUser(
        id: j['id']?.toString() ?? '',
        fullName: j['fullName'] as String? ?? '—',
        position: j['position'] as String?,
        avatarFileId: j['avatarFileId'] as String?,
        avatarUrl: j['avatarUrl'] as String?,
      );

  // Initials cho avatar fallback
  String get initials {
    final parts = fullName.trim().split(' ');
    return parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';
  }
}

// ── Mention trong comment ─────────────────────────────────────────────
// JSON: { "userId": "...", "fullName": "..." }  ← key là userId, không phải id
class CommentMention {
  final String userId;
  final String fullName;

  const CommentMention({required this.userId, required this.fullName});

  factory CommentMention.fromJson(Map<String, dynamic> j) => CommentMention(
        userId: j['userId']?.toString() ?? '',
        fullName: j['fullName'] as String? ?? '—',
      );
}

// ── Attachment trong comment ──────────────────────────────────────────
// JSON: { "id", "commentId", "fileAttachmentId", "fileName" }
// Không có fileUrl trực tiếp → dùng fileAttachmentId để download
class CommentAttachment {
  final String id;
  final String commentId;
  final String
      fileAttachmentId; // dùng GET /api/file/{fileAttachmentId}/download
  final String fileName;

  const CommentAttachment({
    required this.id,
    required this.commentId,
    required this.fileAttachmentId,
    required this.fileName,
  });

  factory CommentAttachment.fromJson(Map<String, dynamic> j) =>
      CommentAttachment(
        id: j['id']?.toString() ?? '',
        commentId: j['commentId']?.toString() ?? '',
        fileAttachmentId: j['fileAttachmentId']?.toString() ?? '',
        fileName: j['fileName'] as String? ?? 'file',
      );

  String get ext =>
      fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';

  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  bool get isPdf => ext == 'pdf';
  bool get isExcel => ['xlsx', 'xls'].contains(ext);
  bool get isWord => ['docx', 'doc'].contains(ext);
}

// ── Comment chính ─────────────────────────────────────────────────────
// systemAction: 1 = phê duyệt, 2 = từ chối (null = comment thường)
// isSystemGenerated: true = tự động tạo khi duyệt/từ chối
class CommentModel {
  final String id;
  final String content;
  final int? systemAction; // 1=approve, 2=reject, null=bình thường
  final bool isSystemGenerated; // true = do hệ thống tạo (hành động duyệt)
  final String documentType;
  final String documentId;
  final String userId;
  final String? createdAt;
  final String? parentCommentId;

  final CommentUser? user; // người tạo comment (có avatar)
  final List<CommentAttachment> attachments;
  final List<CommentModel> replies;
  final List<CommentMention> mentions;

  const CommentModel({
    required this.id,
    required this.content,
    required this.documentType,
    required this.documentId,
    required this.userId,
    this.systemAction,
    this.isSystemGenerated = false,
    this.createdAt,
    this.parentCommentId,
    this.user,
    this.attachments = const [],
    this.replies = const [],
    this.mentions = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> j) => CommentModel(
        id: j['id']?.toString() ?? '',
        content: j['content'] as String? ?? '',
        systemAction: j['systemAction'] as int?,
        isSystemGenerated: j['isSystemGenerated'] as bool? ?? false,
        documentType: j['documentType'] as String? ?? '',
        documentId: j['documentId']?.toString() ?? '',
        userId: j['userId']?.toString() ?? '',
        createdAt: j['createdAt'] as String?,
        parentCommentId: j['parentCommentId']?.toString(),
        user: j['user'] != null
            ? CommentUser.fromJson(j['user'] as Map<String, dynamic>)
            : null,
        attachments: (j['attachments'] as List? ?? [])
            .map((a) => CommentAttachment.fromJson(a as Map<String, dynamic>))
            .toList(),
        replies: (j['replies'] as List? ?? [])
            .map((r) => CommentModel.fromJson(r as Map<String, dynamic>))
            .toList(),
        mentions: (j['mentions'] as List? ?? [])
            .map((m) => CommentMention.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  // Helpers
  bool get isApprovalAction => isSystemGenerated && systemAction != null;
  bool get isApproved => systemAction == 1;
  bool get isRejected => systemAction == 2;
  bool get hasContent => content.isNotEmpty;
  bool get hasAttachments => attachments.isNotEmpty;
}

// ── Upload result (POST /api/file) ────────────────────────────────────
class UploadedFile {
  final String id;
  final String fileName;
  final String? fileUrl;

  const UploadedFile({
    required this.id,
    required this.fileName,
    this.fileUrl,
  });

  factory UploadedFile.fromJson(Map<String, dynamic> j) => UploadedFile(
        id: j['id']?.toString() ?? '',
        fileName: j['fileName'] as String? ?? 'file',
        fileUrl: j['fileUrl'] as String?,
      );
}
