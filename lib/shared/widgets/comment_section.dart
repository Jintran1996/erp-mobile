// lib/features/_shared/ui/comment_section.dart
//
// Widget dùng chung cho mọi detail screen.
// Hiển thị 2 kiểu comment:
//   1. isSystemGenerated = true  → timeline action (duyệt/từ chối)
//   2. isSystemGenerated = false → bubble chat thường (có avatar, file)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/comment_provider.dart';
import '../models/comment_model.dart';
import '../../features/expense/_shared/expense_formatters.dart';

class CommentSection extends StatefulWidget {
  final Color color;
  const CommentSection({super.key, required this.color});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    if (file.path == null) return;
    if (!mounted) return;
    await context
        .read<CommentProvider>()
        .uploadFileFromPath(file.path!, file.name);
  }

  Future<void> _send() async {
    final p = context.read<CommentProvider>();
    final ok = await p.sendComment(_ctrl.text);
    if (ok) {
      _ctrl.clear();
      if (mounted) FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CommentProvider>();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Header ────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(children: [
          Icon(Icons.chat_bubble_outline, size: 18, color: widget.color),
          const SizedBox(width: 8),
          Text('Bình luận',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: widget.color)),
          if (p.comments.isNotEmpty) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${p.comments.length}',
                  style: TextStyle(
                      fontSize: 11,
                      color: widget.color,
                      fontWeight: FontWeight.bold)),
            ),
          ],
          const Spacer(),
          if (p.loading)
            SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: widget.color, strokeWidth: 2)),
        ]),
      ),

      // ── Danh sách ─────────────────────────────────────────────────
      if (p.error != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(p.error!,
              style: const TextStyle(color: Colors.red, fontSize: 12)),
        )
      else if (!p.loading && p.comments.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text('Chưa có bình luận nào',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        )
      else
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: p.comments.length,
          itemBuilder: (_, i) => _CommentItem(
            comment: p.comments[i],
            color: widget.color,
            onReply: (id, name) {
              p.setReplyTo(id, name);
              _focusNode.requestFocus();
            },
          ),
        ),

      // ── Input box ─────────────────────────────────────────────────
      Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(children: [
          // Banner đang reply
          if (p.replyToId != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(children: [
                Icon(Icons.reply, size: 14, color: widget.color),
                const SizedBox(width: 6),
                Expanded(
                    child: Text('Đang phản hồi ${p.replyToName}',
                        style: TextStyle(
                            fontSize: 12,
                            color: widget.color,
                            fontWeight: FontWeight.w500))),
                GestureDetector(
                    onTap: p.clearReplyTo,
                    child: Icon(Icons.close, size: 16, color: widget.color)),
              ]),
            ),

          // Files đang chờ
          if (p.pendingFiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Wrap(spacing: 8, runSpacing: 6, children: [
                for (final f in p.pendingFiles)
                  _PendingChip(
                      file: f, onRemove: () => p.removePendingFile(f.id)),
              ]),
            ),

          // Input row
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: p.replyToId != null
                      ? 'Nhập phản hồi...'
                      : 'Viết bình luận...',
                  hintStyle:
                      TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(12, 10, 0, 10),
                ),
              ),
            ),
            // Upload
            p.uploading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey.shade500),
                    onPressed: _pickFile,
                    tooltip: 'Đính kèm file',
                  ),
            // Gửi
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 4),
              child: p.sending
                  ? const SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))))
                  : IconButton(
                      icon: Icon(Icons.send_rounded, color: widget.color),
                      onPressed: _send,
                      tooltip: 'Gửi'),
            ),
          ]),

          if (p.sendError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(p.sendError!,
                  style: const TextStyle(color: Colors.red, fontSize: 11)),
            ),
        ]),
      ),
      const SizedBox(height: 24),
    ]);
  }
}

// ── Comment item — phân nhánh 2 kiểu ──────────────────────────────────
class _CommentItem extends StatelessWidget {
  final CommentModel comment;
  final Color color;
  final void Function(String id, String name) onReply;

  const _CommentItem({
    required this.comment,
    required this.color,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return comment.isApprovalAction
        ? _SystemActionItem(comment: comment)
        : _NormalCommentItem(comment: comment, color: color, onReply: onReply);
  }
}

// ── Kiểu 1: System action (duyệt/từ chối) ────────────────────────────
// Hiển thị: icon ✅/❌ + avatar nhỏ + text "@Tên đã phê duyệt" + time
class _SystemActionItem extends StatelessWidget {
  final CommentModel comment;
  const _SystemActionItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    final isApprove = comment.isApproved;
    final actionColor =
        isApprove ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final actionBg =
        isApprove ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(children: [
        // Icon hành động
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: actionBg, shape: BoxShape.circle),
          child: Icon(
            isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 16,
            color: actionColor,
          ),
        ),
        const SizedBox(width: 8),
        // Avatar nhỏ
        _AvatarWidget(user: comment.user, radius: 13, color: actionColor),
        const SizedBox(width: 8),
        // Nội dung
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(comment.content,
                style: TextStyle(
                    fontSize: 12,
                    color: actionColor,
                    fontWeight: FontWeight.w500)),
            Text(formatDateTime(comment.createdAt),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ],
        )),
      ]),
    );
  }
}

// ── Kiểu 2: Comment thường (bubble + avatar + file) ───────────────────
class _NormalCommentItem extends StatelessWidget {
  final CommentModel comment;
  final Color color;
  final void Function(String id, String name) onReply;

  const _NormalCommentItem({
    required this.comment,
    required this.color,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final user = comment.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar
          _AvatarWidget(user: user, radius: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bubble
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên + chức vụ
                    if (user != null) ...[
                      Text(user.fullName,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      if (user.position != null)
                        Text(user.position!,
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade400)),
                      const SizedBox(height: 4),
                    ],
                    // Nội dung (nếu rỗng + có file thì không hiện gì)
                    if (comment.hasContent)
                      Text(comment.content,
                          style: const TextStyle(fontSize: 13, height: 1.4)),
                    // Files
                    if (comment.hasAttachments) ...[
                      const SizedBox(height: 8),
                      for (final a in comment.attachments)
                        _AttachmentChip(attachment: a, color: color),
                    ],
                  ],
                ),
              ),
              // Time + Reply
              Padding(
                padding: const EdgeInsets.only(top: 3, left: 4),
                child: Row(children: [
                  Text(formatDateTime(comment.createdAt),
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () =>
                        onReply(comment.id, user?.fullName ?? 'người dùng'),
                    child: Text('Phản hồi',
                        style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w500)),
                  ),
                ]),
              ),
            ],
          )),
        ]),

        // Replies
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 46, top: 4),
            child: Column(children: [
              for (final reply in comment.replies)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AvatarWidget(
                            user: reply.user, radius: 13, color: color),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: color.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (reply.user != null)
                                Text(reply.user!.fullName,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                              if (reply.hasContent)
                                Text(reply.content,
                                    style: const TextStyle(
                                        fontSize: 12, height: 1.4)),
                              for (final a in reply.attachments)
                                _AttachmentChip(attachment: a, color: color),
                              Text(formatDateTime(reply.createdAt),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade400)),
                            ],
                          ),
                        )),
                      ]),
                ),
            ]),
          ),
      ]),
    );
  }
}

// ── Avatar widget ─────────────────────────────────────────────────────
class _AvatarWidget extends StatelessWidget {
  final CommentUser? user;
  final double radius;
  final Color color;

  const _AvatarWidget({this.user, required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    final url = user?.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url),
        backgroundColor: Colors.grey.shade100,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        user?.initials ?? '?',
        style: TextStyle(
          fontSize: radius * 0.65,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// ── Attachment chip trong comment ─────────────────────────────────────
// Download qua GET /api/file/{fileAttachmentId}/download
class _AttachmentChip extends StatelessWidget {
  final CommentAttachment attachment;
  final Color color;

  const _AttachmentChip({required this.attachment, required this.color});

  @override
  Widget build(BuildContext context) {
    final isImg = attachment.isImage;
    final clr = isImg ? const Color(0xFF0891B2) : color;
    final bg = isImg ? const Color(0xFFE0F2FE) : color.withValues(alpha: 0.07);
    final icon = isImg
        ? Icons.image_outlined
        : attachment.isPdf
            ? Icons.picture_as_pdf
            : attachment.isExcel
                ? Icons.table_chart_outlined
                : attachment.isWord
                    ? Icons.description_outlined
                    : Icons.attach_file;

    return GestureDetector(
      onTap: () {
        // TODO: mở GET /api/file/{fileAttachmentId}/download
        // Có thể dùng url_launcher hoặc dio download
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: clr.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: clr),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(attachment.fileName,
                style: TextStyle(fontSize: 11, color: clr),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 4),
          Icon(Icons.download_outlined,
              size: 12, color: clr.withValues(alpha: 0.7)),
        ]),
      ),
    );
  }
}

// ── Pending file chip (trước khi gửi) ────────────────────────────────
class _PendingChip extends StatelessWidget {
  final UploadedFile file;
  final VoidCallback onRemove;

  const _PendingChip({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.attach_file, size: 13, color: Color(0xFF2563EB)),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(file.fileName,
              style: const TextStyle(fontSize: 11, color: Color(0xFF1D4ED8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close, size: 13, color: Color(0xFF2563EB)),
        ),
      ]),
    );
  }
}
