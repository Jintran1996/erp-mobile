// lib/providers/comment_provider.dart
//
// Vị trí : lib/providers/    ← Provider tầng toàn cục
// Dùng chung cho tất cả form detail.
// Screen chỉ gọi provider.method() và watch state.

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/models/comment_model.dart';
import '../repositories/comment_repository.dart';

class CommentProvider extends ChangeNotifier {
  final _repo = CommentRepository.instance;

  // ── Params nhận từ Screen ─────────────────────────────────────────
  late String _documentId;
  late String _documentType;

  void init(String documentId, String documentType) {
    _documentId = documentId;
    _documentType = documentType;
  }

  // ── State: danh sách comment ──────────────────────────────────────
  List<CommentModel> _comments = [];
  bool _loading = false;
  String? _error;

  List<CommentModel> get comments => _comments;
  bool get loading => _loading;
  String? get error => _error;

  // ── State: đang nhập comment mới ──────────────────────────────────
  String? _replyToId; // null = comment mới, có id = đang reply
  String? _replyToName; // tên người được reply (hiển thị trên input)
  List<UploadedFile> _pendingFiles = []; // files đã upload, chờ gửi kèm comment
  bool _sending = false;
  bool _uploading = false;
  String? _sendError;

  String? get replyToId => _replyToId;
  String? get replyToName => _replyToName;
  List<UploadedFile> get pendingFiles => _pendingFiles;
  bool get sending => _sending;
  bool get uploading => _uploading;
  String? get sendError => _sendError;

  // ── Load comments ─────────────────────────────────────────────────
  Future<void> loadComments() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _comments = await _repo.getComments(
        documentId: _documentId,
        documentType: _documentType,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Chọn reply ────────────────────────────────────────────────────
  void setReplyTo(String commentId, String userName) {
    _replyToId = commentId;
    _replyToName = userName;
    notifyListeners();
  }

  void clearReplyTo() {
    _replyToId = null;
    _replyToName = null;
    notifyListeners();
  }

  // ── Upload file ───────────────────────────────────────────────────
  Future<void> uploadFileFromPath(String path, String name) async {
    _uploading = true;
    _sendError = null;
    notifyListeners();

    try {
      final uploaded = await _repo.uploadFile(File(path), name);
      _pendingFiles = [..._pendingFiles, uploaded];
    } catch (e) {
      _sendError = e.toString();
    } finally {
      _uploading = false;
      notifyListeners();
    }
  }

  void removePendingFile(String fileId) {
    _pendingFiles = _pendingFiles.where((f) => f.id != fileId).toList();
    notifyListeners();
  }

  // ── Gửi comment / reply ───────────────────────────────────────────
  Future<bool> sendComment(String content) async {
    if (content.trim().isEmpty && _pendingFiles.isEmpty) return false;

    _sending = true;
    _sendError = null;
    notifyListeners();

    try {
      final attachmentIds = _pendingFiles.map((f) => f.id).toList();

      CommentModel newComment;

      if (_replyToId != null) {
        newComment = await _repo.replyComment(
          parentId: _replyToId!,
          documentId: _documentId,
          documentType: _documentType,
          content: content.trim(),
          attachmentIds: attachmentIds,
        );
        // Chèn reply vào đúng parent trong list
        _comments = _comments.map((c) {
          if (c.id == _replyToId) {
            return CommentModel(
              id: c.id,
              content: c.content,
              documentType: c.documentType,
              documentId: c.documentId,
              userId: c.userId,
              systemAction: c.systemAction,
              isSystemGenerated: c.isSystemGenerated,
              createdAt: c.createdAt,
              parentCommentId: c.parentCommentId,
              user: c.user,
              attachments: c.attachments,
              mentions: c.mentions,
              replies: [...c.replies, newComment],
            );
          }
          return c;
        }).toList();
      } else {
        newComment = await _repo.postComment(
          documentId: _documentId,
          documentType: _documentType,
          content: content.trim(),
          attachmentIds: attachmentIds,
        );
        // Thêm vào đầu danh sách (mới nhất lên trên)
        _comments = [newComment, ..._comments];
      }

      // Reset sau khi gửi thành công
      _pendingFiles = [];
      _replyToId = null;
      _replyToName = null;
      return true;
    } catch (e) {
      _sendError = e.toString();
      return false;
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
