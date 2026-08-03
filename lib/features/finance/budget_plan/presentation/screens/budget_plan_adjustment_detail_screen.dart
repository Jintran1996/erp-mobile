// lib/features/finance/budget_plan/presentation/screens/budget_plan_adjustment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_plan_adjustment_detail_provider.dart';
import '../../data/models/budget_plan_adjustment_model.dart';
import '../../data/models/budget_plan_model.dart';
import '../../../../../shared/providers/comment_provider.dart';
import '../../../../../shared/widgets/comment_section.dart';
import '../../../../../features/_shared/ui/section_widgets.dart';
import '../../../../../features/expense/_shared/expense_formatters.dart';
import '../../../../../core/constants/document_types.dart';
import '../../../../../features/auth/data/auth_service.dart';

class BudgetPlanAdjustmentDetailScreen extends StatelessWidget {
  final String id;
  static const Color _color = Color(0xFF2563EB);

  const BudgetPlanAdjustmentDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => BudgetPlanAdjustmentDetailProvider()..load(id)),
        ChangeNotifierProvider(
            create: (_) => CommentProvider()
              ..init(id, DocumentType.budgetPlanAdjustment.value.toString())
              ..loadComments()),
      ],
      child: _AdjustmentDetailView(id: id),
    );
  }
}

class _AdjustmentDetailView extends StatelessWidget {
  final String id;
  static const Color color = BudgetPlanAdjustmentDetailScreen._color;

  const _AdjustmentDetailView({required this.id});

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
    final p = context.watch<BudgetPlanAdjustmentDetailProvider>();
    final userId = AuthService.instance.userId;

    // Hiện action bar khi: là reviewer & được review, HOẶC là approver & được approve
    final canAct = !p.loading &&
        p.error == null &&
        p.detail != null &&
        ((p.detail!.reviewer?.id == userId &&
                p.detail!.canReview == true &&
                p.detail!.canApprove == false &&
                p.detail?.status == 0) ||
            (p.detail!.approver?.id == userId &&
                p.detail!.canReview == false &&
                p.detail!.canApprove == true &&
                p.detail?.status == 1));

    return Scaffold(
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
          canAct ? _buildActionBar(context, p.detail!, p) : null,
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, BudgetPlanAdjustmentDetailModel d) {
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
            'Bổ sung NS - T${d.periodMonth}/${d.periodYear}',
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
              context.read<BudgetPlanAdjustmentDetailProvider>().load(id);
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
  Widget _buildError(
      BuildContext context, BudgetPlanAdjustmentDetailProvider p) {
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

  // ── Body ──────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, BudgetPlanAdjustmentDetailModel d,
      BudgetPlanAdjustmentDetailProvider p) {
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

        // Lý do bổ sung
        if (d.reason != null && d.reason!.isNotEmpty) ...[
          expenseSection(
            icon: Icons.notes_outlined,
            title: 'Lý do bổ sung',
            color: color,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(d.reason!, style: const TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Luồng duyệt
        expenseSection(
          icon: Icons.account_tree_outlined,
          title: 'Luồng duyệt',
          color: color,
          child: _buildApprovalFlow(d),
        ),
        const SizedBox(height: 8),

        // Hạng mục bổ sung
        expenseSection(
          icon: Icons.list_alt_outlined,
          title: 'Hạng mục bổ sung',
          color: color,
          child: d.items.isEmpty
              ? expenseEmptyHint('Không có hạng mục')
              : _buildLineItems(d),
        ),

        // Lý do trả lại
        if (d.returnReason != null && d.returnReason!.isNotEmpty) ...[
          const SizedBox(height: 8),
          expenseSection(
            icon: Icons.info_outline,
            title: 'Lý do trả lại',
            color: const Color(0xFFDC2626),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(d.returnReason!,
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

  // ── Thông tin chung ───────────────────────────────────────────────
  Widget _buildInfoGeneral(
      BuildContext context, BudgetPlanAdjustmentDetailModel d) {
    return Column(children: [
      expenseInfoRow('Phòng ban', d.departmentDisplay,
          copyable: true, onCopy: () => _copy(context, d.departmentDisplay)),
      expenseInfoRow(
          'Kỳ ngân sách', 'Tháng ${d.periodMonth} / Năm ${d.periodYear}'),
      expenseInfoRow('Tạo bởi', d.createdByUser?.fullName ?? '-'),
      expenseInfoRow('Tạo lúc', formatDateTime(d.createdAt)),
    ]);
  }

  // ── Luồng duyệt ───────────────────────────────────────────────────
  Widget _buildApprovalFlow(BudgetPlanAdjustmentDetailModel d) {
    final steps = <_AdjustmentApprovalStep>[
      _AdjustmentApprovalStep(
        label: 'Xem xét',
        user: d.reviewer,
        isDone: d.reviewedAt != null,
        doneAt: d.reviewedAt,
        isReject: false,
      ),
      _AdjustmentApprovalStep(
        label: 'Phê duyệt',
        user: d.approver,
        isDone: d.approvedAt != null,
        doneAt: d.approvedAt,
        isReject: false,
      ),
      if (d.returnedBy != null)
        _AdjustmentApprovalStep(
          label: 'Trả lại',
          user: d.returnedBy,
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
                  if (step.user != null)
                    expensePersonRow(
                      name: step.user!.fullName,
                      position: step.user!.position,
                      color: color,
                      avatarUrl: step.user!.avatarUrl,
                    )
                  else
                    expenseEmptyHint('Chưa xác định'),
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

  // ── Hạng mục bổ sung ──────────────────────────────────────────────
  Widget _buildLineItems(BudgetPlanAdjustmentDetailModel d) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final num totalAmount = d.items.fold(0, (sum, item) => sum + item.amount);

    return Column(children: [
      // Header
      const Row(children: [
        Expanded(
            flex: 5,
            child: Text('Mã ngân sách',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
        Expanded(
            flex: 3,
            child: Text('Số tiền bổ sung',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
      Divider(height: 12, color: Colors.grey.shade200),

      // Rows
      for (final item in d.items) ...[
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.displayCode,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  if (item.note != null && item.note!.isNotEmpty)
                    Text(item.note!,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic)),
                ],
              )),
          Expanded(
              flex: 3,
              child: Text('${fmt.format(item.amount)} đ',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500))),
        ]),
        Divider(height: 14, color: Colors.grey.shade100),
      ],

      // Total
      Row(children: [
        const Expanded(
            flex: 5,
            child: Text('Tổng cộng',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        Expanded(
            flex: 3,
            child: Text('${fmt.format(totalAmount)} đ',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: color))),
      ]),
    ]);
  }

  // ── Bottom action bar ─────────────────────────────────────────────
  Widget _buildActionBar(BuildContext ctx, BudgetPlanAdjustmentDetailModel d,
      BudgetPlanAdjustmentDetailProvider p) {
    // Đang ở bước review hay approve?
    final userId = AuthService.instance.userId;
    final isReviewStep = d.canReview && d.reviewer?.id == userId;
    final actionLabel = isReviewStep ? 'Xem xét' : 'Duyệt';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                p.acting ? null : () => _showConfirm(ctx, p, isReviewStep),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            child: p.acting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(actionLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: p.acting ? null : () => _showReject(ctx, p),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            child: const Text('Từ chối',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }

  void _showConfirm(BuildContext ctx, BudgetPlanAdjustmentDetailProvider p,
      bool isReviewStep) {
    final label = isReviewStep ? 'xem xét' : 'duyệt';
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: Text('Xác nhận ${isReviewStep ? 'xem xét' : 'duyệt'}'),
              content: Text('Bạn có chắc muốn $label bổ sung ngân sách này?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final ok =
                        isReviewStep ? await p.review(id) : await p.approve(id);
                    if (ctx.mounted) {
                      ctx.read<BudgetPlanAdjustmentDetailProvider>().load(id);
                      ctx.read<CommentProvider>().loadComments();
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(ok
                            ? (isReviewStep ? '✅ Đã xem xét' : '✅ Đã duyệt')
                            : '❌ Thao tác thất bại'),
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

  void _showReject(BuildContext ctx, BudgetPlanAdjustmentDetailProvider p) {
    final ctrl = TextEditingController();
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              title: const Text('Trả lại bổ sung'),
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
                      ctx.read<BudgetPlanAdjustmentDetailProvider>().load(id);
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
class _AdjustmentApprovalStep {
  final String label;
  final BudgetPlanUser? user;
  final bool isDone;
  final String? doneAt;
  final bool isReject;

  const _AdjustmentApprovalStep({
    required this.label,
    required this.isDone,
    required this.isReject,
    this.user,
    this.doneAt,
  });
}
