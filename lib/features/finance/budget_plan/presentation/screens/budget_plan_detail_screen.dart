// lib/features/finance/budget_plan/presentation/screens/budget_plan_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_plan_detail_provider.dart';
import '../../data/models/budget_plan_model.dart';
import '../../../../../shared/providers/comment_provider.dart';
import '../../../../../shared/widgets/comment_section.dart';
import '../../../../../features/_shared/ui/section_widgets.dart';
import '../../../../../features/expense/_shared/expense_formatters.dart';
import '../../../../../core/constants/document_types.dart';
import '../../../../auth/data/auth_service.dart';
import '../../../../_shared/widgets/dynamic_action_bar.dart';

class BudgetPlanDetailScreen extends StatelessWidget {
  final String id;
  static const Color _color = Color(0xFF2563EB);

  const BudgetPlanDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => BudgetPlanDetailProvider()..load(id)),
        ChangeNotifierProvider(
            create: (_) => CommentProvider()
              ..init(
                  id, DocumentType.budgetPlan.value.toString()) // 'budget-plan'
              ..loadComments()),
      ],
      child: _BudgetPlanDetailView(id: id),
    );
  }
}

class _BudgetPlanDetailView extends StatelessWidget {
  final String id;
  static const Color color = BudgetPlanDetailScreen._color;

  const _BudgetPlanDetailView({required this.id});

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Đã sao chép'),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BudgetPlanDetailProvider>();
    final showActionBar = !p.loading &&
        p.error == null &&
        p.detail != null &&
        ((p.detail!.reviewer?.id == AuthService.instance.userId &&
                p.detail!.canReview == true &&
                p.detail!.canApprove == false &&
                p.detail?.status == 0) ||
            (p.detail!.approver?.id == AuthService.instance.userId &&
                p.detail!.canReview == false &&
                p.detail!.canApprove == true &&
                p.detail?.status == 1));

    return Scaffold(
      //backgroundColor: const Color(0xFFF1F5F9),
      backgroundColor: Colors.white,
      appBar: p.loading || p.error != null || p.detail == null
          ? AppBar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0)
          : _buildAppBar(context, p.detail!),
      body: p.loading
          ? const Center(child: CircularProgressIndicator(color: color))
          : p.error != null
              ? _buildError(context, p)
              : _buildBody(context, p.detail!, p),
      bottomNavigationBar:
          showActionBar ? _buildActionBar(context, p.detail!, p) : null,
    );
  }

  // ── AppBar — Thiết kế Gradient (Nền xanh chuyển màu, giữ điểm nhấn mạnh mẽ) ─────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, BudgetPlanDetailModel d) {
    final cfg = d.statusCfg;

    return AppBar(
      elevation: 0, // Loại bỏ đổ bóng thô để dải Gradient mượt mà hơn
      centerTitle: false, // Căn trái tiêu đề tạo cảm giác hiện đại

      // Tạo hiệu ứng chuyển màu Gradient từ xanh sáng sang xanh đậm hơn
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 56, 113, 236), // Xanh Royal Blue sáng
              Color.fromARGB(255, 53, 154, 236), // Xanh Royal Blue sáng
              Color(0xFF1D4ED8), // Xanh đậm tạo chiều sâu
            ],
          ),
          // --- THÊM HIỆU ỨNG ĐỔ BÓNG SIÊU MƯỢT DƯỚI ĐÁY APPBAR ---
        ),
      ),

      // Nút quay lại (Màu trắng đồng bộ nền xanh)
      leading: IconButton(
        icon:
            const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
        onPressed: () => Navigator.pop(context),
      ),

      // Tiêu đề chính lồng cấu trúc hàng thông tin bên dưới
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Chi tiết NS - T${d.periodMonth}/${d.periodYear}',
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // Hàng chứa cả Badge và Thời gian thu gọn bên dưới tiêu đề
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(
                      cfg.bg), // Giữ nguyên màu nền động từ hệ thống của bạn
                  borderRadius:
                      BorderRadius.circular(6), // Bo góc vuông vắn hiện đại
                ),
                child: Text(
                  cfg.label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(cfg.text)), // Giữ nguyên màu chữ động
                ),
              ),
              const SizedBox(width: 8),

              // Thời gian mờ nhẹ tinh tế
              Flexible(
                child: Text(
                  formatDateTime(d.createdAt),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),

      // Khối chứa các nút chức năng bên phải
      actions: [
        // Nút Tải lại dữ liệu
        IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 22),
            onPressed: () {
              context.read<BudgetPlanDetailProvider>().load(id);
              context.read<CommentProvider>().loadComments();
            }),

        const SizedBox(width: 2), // Khoảng cách an toàn giữa 2 icon

        // Nút Home quay về trang chủ
        IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.white, size: 22),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),

        const SizedBox(width: 8), // Khoảng đệm sát rìa màn hình phải
      ],
    );
  }

  // ── Error ─────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, BudgetPlanDetailProvider p) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
            const SizedBox(height: 12),
            Text(p.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => p.load(id),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: color, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body — chuẩn expense: moneyRow + sections ─────────────────────
  Widget _buildBody(BuildContext context, BudgetPlanDetailModel d,
      BudgetPlanDetailProvider p) {
    return SingleChildScrollView(
      child: Column(children: [
        // Thông tin chung
        expenseSection(
          icon: Icons.info_outline,
          title: 'Thông tin chung',
          color: color,
          child: _buildInfoGeneral(context, d),
        ),
        const SizedBox(height: 8),

        // Luồng duyệt
        expenseSection(
          icon: Icons.account_tree_outlined,
          title: 'Luồng duyệt',
          color: color,
          child: _buildApprovalFlow(d),
        ),
        const SizedBox(height: 8),

        // Hạng mục ngân sách
        expenseSection(
          icon: Icons.list_alt_outlined,
          title: 'Hạng mục ngân sách',
          color: color,
          child: d.items.isEmpty
              ? expenseEmptyHint('Không có hạng mục')
              : _buildLineItems(d),
        ),

        // Lý do trả lại / hủy
        if (d.returnReason != null || d.cancelledReason != null) ...[
          const SizedBox(height: 8),
          expenseSection(
            icon: Icons.info_outline,
            title: d.returnReason != null ? 'Lý do trả lại' : 'Lý do hủy',
            color: const Color(0xFFDC2626),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(d.returnReason ?? d.cancelledReason ?? '',
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF991B1B))),
            ),
          ),
        ],

        // Comment
        const CommentSection(color: color),
        const SizedBox(height: 30),
      ]),
    );
  }

  // ── Thông tin chung — dùng expenseInfoRow ─────────────────────────
  Widget _buildInfoGeneral(BuildContext context, BudgetPlanDetailModel d) {
    return Column(children: [
      expenseInfoRow('Phòng ban', d.departmentDisplay,
          copyable: true, onCopy: () => _copy(context, d.departmentDisplay)),
      expenseInfoRow(
          'Kỳ ngân sách', 'Tháng ${d.periodMonth} / Năm ${d.periodYear}'),
      expenseInfoRow('Tạo bởi', d.createdByUser?.fullName ?? '-'),
      expenseInfoRow('Tạo lúc', formatDateTime(d.createdAt)),
    ]);
  }

  // ── Luồng duyệt — chuẩn expense (dot + line + approver info) ─────
  Widget _buildApprovalFlow(BudgetPlanDetailModel d) {
    final steps = <_BudgetApprovalStep>[
      _BudgetApprovalStep(
        label: 'Xem xét',
        user: d.reviewer,
        isDone: d.reviewedAt != null,
        doneAt: d.reviewedAt,
        isReject: false,
      ),
      _BudgetApprovalStep(
        label: 'Phê duyệt',
        user: d.approver,
        isDone: d.approvedAt != null,
        doneAt: d.approvedAt,
        isReject: false,
      ),
      if (d.returnedBy != null)
        _BudgetApprovalStep(
          label: 'Trả lại',
          user: d.returnedBy,
          isDone: true,
          isReject: true,
        ),
      if (d.cancelledBy != null)
        _BudgetApprovalStep(
          label: 'Đã hủy',
          user: d.cancelledBy,
          isDone: true,
          isReject: true,
        ),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final dotColor = step.isReject
            ? const Color(0xFFDC2626)
            : step.isDone
                ? const Color(0xFF059669)
                : Colors.grey.shade300;

        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Dot + line
            Column(children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: step.isDone ? 0.15 : 0.07),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: dotColor, width: step.isDone ? 1.5 : 1),
                ),
                child: Center(
                  child: step.isReject
                      ? Icon(Icons.reply, size: 14, color: dotColor)
                      : step.isDone
                          ? Icon(Icons.check, size: 14, color: dotColor)
                          : Icon(Icons.radio_button_unchecked,
                              size: 14, color: dotColor),
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                    child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        color: dotColor.withValues(alpha: 0.3))),
            ]),
            const SizedBox(width: 10),

            // Content
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 16 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              step.isDone ? dotColor : Colors.grey.shade500)),
                  const SizedBox(height: 4),

                  // Avatar + tên
                  if (step.user != null)
                    expensePersonRow(
                      name: step.user!.fullName,
                      position: step.user!.position,
                      color: color,
                      avatarUrl: step.user!.avatarUrl,
                    )
                  else
                    expenseEmptyHint('Chưa xác định'),

                  // Thời gian hoàn thành
                  if (step.doneAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        formatDateTime(step.doneAt),
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400),
                      ),
                    ),
                ],
              ),
            )),
          ]),
        );
      }),
    );
  }

  // ── Hạng mục — chuẩn expense (header + rows + total) ─────────────
  Widget _buildLineItems(BudgetPlanDetailModel d) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final num totalPlanAmount =
        d.items.fold(0, (sum, item) => sum + item.planAmount);
    final num totalUsedAmount =
        d.items.fold(0, (sum, item) => sum + item.usedAmount);
    final num totalRemainingAmount = totalPlanAmount - totalUsedAmount;

    return Column(children: [
      // Header: Thay đổi tỷ lệ flex từ (4-2-2-2) thành (3-2.3-2.3-2.3) để tăng diện tích hiển thị số tiền
      // Đưa đơn vị (đ) lên tiêu đề cột để các dòng dưới không bị lặp chữ "đ" gây tràn dòng
      const Row(children: [
        Expanded(
            flex: 30, // Tương đương flex: 3
            child: Text('Mã ngân sách',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
        Expanded(
            flex: 23, // Tương đương flex: 2.3
            child: Text('Kế hoạch (đ)',
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
        Expanded(
            flex: 23,
            child: Text('Đã dùng (đ)',
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
        Expanded(
            flex: 23,
            child: Text('Còn lại (đ)',
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
      Divider(height: 12, color: Colors.grey.shade200),

      // Rows
      for (final item in d.items) ...[
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              flex: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.displayCode,
                      // XÓA maxLines và overflow ở đây để chữ tự động xuống dòng khi dài
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  if (item.budgetGroupName != null)
                    Text(item.budgetGroupName!,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400),
                        maxLines:
                            2, // Cho phép tên nhóm ngân sách xuống tối đa 2 dòng
                        overflow: TextOverflow.ellipsis),
                  if (item.note != null)
                    Text(item.note!,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic)),
                ],
              )),
          // Loại bỏ chữ "đ" ở cuối chuỗi số, ép hiển thị tối đa 1 dòng và tự động thu nhỏ nếu tràn (Dùng FittedBox)
          Expanded(
              flex: 23,
              child: Align(
                alignment: Alignment.topRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(fmt.format(item.planAmount),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12)),
                ),
              )),
          Expanded(
              flex: 23,
              child: Align(
                alignment: Alignment.topRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(fmt.format(item.usedAmount),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          color: item.usedAmount > item.planAmount
                              ? const Color(0xFFDC2626)
                              : Colors.grey.shade700)),
                ),
              )),
          Expanded(
              flex: 23,
              child: Align(
                alignment: Alignment.topRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(fmt.format(item.remainingAmount),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: item.remainingAmount < 0
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF059669))),
                ),
              )),
        ]),
        Divider(height: 14, color: Colors.grey.shade100),
      ],

      // Total — giống expense
      Row(children: [
        const Expanded(
            flex: 30,
            child: Text('Tổng cộng',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        Expanded(
            flex: 23,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(fmt.format(totalPlanAmount),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
            )),
        Expanded(
            flex: 23,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(fmt.format(totalUsedAmount),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: totalUsedAmount > totalPlanAmount
                          ? const Color(0xFFDC2626)
                          : Colors.blue.shade400)),
            )),
        Expanded(
            flex: 23,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(fmt.format(totalRemainingAmount),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: totalRemainingAmount < 0
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF059669))),
            )),
      ]),
    ]);
  }

  // ── Bottom action bar — giống expense ────────────────────────────
  Widget _buildActionBar(
      BuildContext ctx, BudgetPlanDetailModel d, BudgetPlanDetailProvider p) {
    final isReviewer = d.reviewer?.id == AuthService.instance.userId &&
        d.canReview == true &&
        d.canApprove == false &&
        d.status == 0;
    final isApprover = d.approver?.id == AuthService.instance.userId &&
        d.canApprove == true &&
        d.canReview == false &&
        d.status == 1;
    final approveText = isReviewer ? 'Xem xét' : 'Duyệt';
    // final rejectText = isReviewer ? 'Trả lại' : 'Từ chối';

    // Gọi Widget dùng chung đã chuẩn hóa
    return DynamicActionBar(
      primaryText: approveText,
      isLoading: p.acting,
      onSecondaryPressed: () => _showReject(ctx, p),
      onPrimaryPressed: () {
        if (isReviewer && d.canReview == true) {
          _showReviewConfirm(ctx, p);
        } else if (isApprover && d.canApprove == true) {
          _showApproveConfirm(ctx, p);
        }
      },
    );
  }

  void _showReviewConfirm(BuildContext ctx, BudgetPlanDetailProvider p) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: const Text('Xác nhận duyệt'),
              content:
                  const Text('Bạn có chắc muốn duyệt kế hoạch ngân sách này?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final ok = await p.review(id);
                    if (ctx.mounted) {
                      ctx.read<BudgetPlanDetailProvider>().load(id);
                      ctx.read<CommentProvider>().loadComments();
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(ok ? '✅ Đã duyệt' : '❌ Duyệt thất bại'),
                        backgroundColor:
                            ok ? const Color(0xFF059669) : Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white),
                  child: const Text('Xác nhận'),
                ),
              ],
            ));
  }

  void _showApproveConfirm(BuildContext ctx, BudgetPlanDetailProvider p) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: const Text('Xác nhận duyệt'),
              content:
                  const Text('Bạn có chắc muốn duyệt kế hoạch ngân sách này?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final ok = await p.approve(id);
                    if (ctx.mounted) {
                      ctx.read<BudgetPlanDetailProvider>().load(id);
                      ctx.read<CommentProvider>().loadComments();
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(ok ? '✅ Đã duyệt' : '❌ Duyệt thất bại'),
                        backgroundColor:
                            ok ? const Color(0xFF059669) : Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white),
                  child: const Text('Xác nhận'),
                ),
              ],
            ));
  }

  void _showReject(BuildContext ctx, BudgetPlanDetailProvider p) {
    final ctrl = TextEditingController();
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: const Text('Trả lại kế hoạch'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Vui lòng nhập lý do trả lại:'),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Nhập lý do...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    if (ctrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final ok = await p.reject(id, ctrl.text.trim());
                    if (ctx.mounted) {
                      ctx.read<BudgetPlanDetailProvider>().load(id);
                      ctx.read<CommentProvider>().loadComments();
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(ok ? '↩️ Đã trả lại' : '❌ Thất bại'),
                        backgroundColor: const Color(0xFFDC2626),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white),
                  child: const Text('Trả lại'),
                ),
              ],
            ));
  }
}

// ── Data class cho approval step ──────────────────────────────────────
class _BudgetApprovalStep {
  final String label;
  final BudgetPlanUser? user;
  final bool isDone;
  final String? doneAt;
  final bool isReject;

  const _BudgetApprovalStep({
    required this.label,
    required this.isDone,
    required this.isReject,
    this.user,
    this.doneAt,
  });
}
