// lib/repositories/comment_repository.dart
//
// Vị trí : lib/repositories/    ← Repository tầng toàn cục
// Phục vụ tất cả form detail (payment, advance, settlement).
// documentType phân biệt loại phiếu:
//   "ExpensePayment" | "AdvancePayment" | "AdvanceSettlement"

import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../models/comment_model.dart';

class CommentRepository {
  CommentRepository._();
  static final CommentRepository instance = CommentRepository._();

  final _api = ApiClient.instance;

  // ── Lấy danh sách comment ─────────────────────────────────────────
  Future<List<CommentModel>> getComments({
    required String documentId,
    required String documentType,
  }) async {
    final res = await _api.get('/api/comments', params: {
      'documentId': documentId,
      'documentType': documentType,
    });

    final raw = res['data'];
    final list = (raw is List ? raw : []);
    return list
        .map((j) => CommentModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // ── Đăng comment mới ─────────────────────────────────────────────
  Future<CommentModel> postComment({
    required String documentId,
    required String documentType,
    required String content,
    List<String> attachmentIds = const [],
    List<String> mentionIds = const [],
  }) async {
    final res = await _api.post('/api/comments', body: {
      'documentId': documentId,
      'documentType': documentType,
      'content': content,
      if (attachmentIds.isNotEmpty) 'attachmentIds': attachmentIds,
      if (mentionIds.isNotEmpty) 'mentionIds': mentionIds,
    });

    if (res['isSuccess'] != true) {
      throw CommentException(
          res['message'] as String? ?? 'Gửi bình luận thất bại');
    }
    return CommentModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  // ── Reply comment ─────────────────────────────────────────────────
  Future<CommentModel> replyComment({
    required String parentId,
    required String documentId,
    required String documentType,
    required String content,
    List<String> attachmentIds = const [],
    List<String> mentionIds = const [],
  }) async {
    final res = await _api.post('/api/comments/$parentId/reply', body: {
      'documentId': documentId,
      'documentType': documentType,
      'content': content,
      if (attachmentIds.isNotEmpty) 'attachmentIds': attachmentIds,
      if (mentionIds.isNotEmpty) 'mentionIds': mentionIds,
    });

    if (res['isSuccess'] != true) {
      throw CommentException(
          res['message'] as String? ?? 'Gửi phản hồi thất bại');
    }
    return CommentModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  // ── Upload file ───────────────────────────────────────────────────
  // Bước 1: upload → lấy fileId
  // Bước 2: gửi fileId kèm theo comment
  Future<UploadedFile> uploadFile(File file, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split(Platform.pathSeparator).last,
      ),
    });

    // Dùng Dio trực tiếp để gửi multipart
    final dio = Dio(BaseOptions(baseUrl: _api.baseUrl));
    final token = _api.currentToken;
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    final response = await dio.post('/api/file', data: formData);
    final res = response.data as Map<String, dynamic>;

    if (res['isSuccess'] != true) {
      throw CommentException(
          res['message'] as String? ?? 'Upload file thất bại');
    }
    return UploadedFile.fromJson(res['data'] as Map<String, dynamic>);
  }
}

class CommentException implements Exception {
  final String message;
  const CommentException(this.message);
  @override
  String toString() => message;
}
