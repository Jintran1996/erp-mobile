// lib/features/expense/advance_payments_detail_screen.dart
// Screen chỉ lo UI — watch AdvanceDetailProvider.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../presentation/payment_provider.dart';
import '../../expense/data/payment_model.dart';
import '../../expense/data/advance_model.dart';
//import '../../_shared/countdown_timer.dart';
import '../../_shared/ui/chips.dart';
import '../../_shared/ui/section_widgets.dart';
import '../_shared/expense_status.dart';
import '../_shared/expense_formatters.dart';
import '../../../providers/comment_provider.dart';
import '../../_shared/ui/comment_section.dart';

class AdvancePaymentsDetailScreen extends StatelessWidget {
  final String id;
  final Color color;

  const AdvancePaymentsDetailScreen(
      {super.key, required this.id, required this.color});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AdvanceDetailProvider()..load(id)),
        ChangeNotifierProvider(
            create: (_) => CommentProvider()
              ..init(id, 'advance-payment')
              ..loadComments()),
      ],
      child: _AdvanceDetailView(id: id, color: color),
    );
  }
}

class _AdvanceDetailView extends StatelessWidget {
  final String id;
  final Color color;

  const _AdvanceDetailView({required this.id, required this.color});

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
    final p = context.watch<AdvanceDetailProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: p.loading || p.error != null || p.detail == null
          ? AppBar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0)
          : _buildAppBar(context, p.detail!),
      body: p.loading
          ? Center(child: CircularProgressIndicator(color: color))
          : p.error != null
              ? _buildError(context, p)
              : _buildBody(context, p.detail!, p),
      bottomNavigationBar: (!p.loading && p.error == null && p.detail != null)
          ? _buildBottomActionBar(context, p.detail!, p)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AdvanceDetail d) {
    final cfg = getStatusCfg(d.status);
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        color: color,
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 8, 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.subId,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  statusBadge(
                      label: cfg.label, bg: cfg.bg, fg: cfg.text, fontSize: 11),
                  const SizedBox(width: 8),
                  Flexible(
                      child: Text(formatDateTime(d.createdAt),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                          overflow: TextOverflow.ellipsis)),
                  if (d.isForeignPayment) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Ngoại tệ',
                          style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ]),
              ],
            )),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () => context.read<AdvanceDetailProvider>().load(id),
            ),
            IconButton(
              icon: const Icon(Icons.home_outlined, color: Colors.white),
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            ),
          ]),
        )),
      ),
    );
  }

  Widget _buildError(BuildContext context, AdvanceDetailProvider p) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
      ]),
    ));
  }

  Widget _buildBody(
      BuildContext context, AdvanceDetail d, AdvanceDetailProvider p) {
    return SingleChildScrollView(
        child: Column(children: [
      // Tiền
      expenseMoneyRow([
        MoneyCell(
            'Số tiền TU',
            '${formatMoney(d.baseTotalAmount)} ${d.baseCurrencyCode}',
            const Color(0xFF059669),
            large: true),
        if (d.isForeignPayment && d.originalTotalAmount != null)
          MoneyCell(
              'Nguyên tệ',
              '${formatMoney(d.originalTotalAmount)} ${d.originalCurrencyCode}',
              const Color(0xFF2563EB)),
      ]),
      const SizedBox(height: 8),

      // Quyết toán
      if (d.hasSettlement) ...[
        _buildSettlementBanner(d),
        const SizedBox(height: 8),
      ],

      expenseSection(
        icon: Icons.info_outline,
        title: 'Thông tin chung',
        color: color,
        child: _buildInfoGeneral(context, d),
      ),
      const SizedBox(height: 8),
      expenseSection(
        icon: Icons.account_balance_outlined,
        title: 'Thanh toán cho',
        color: color,
        child: _buildPaymentTo(context, d),
      ),
      if (d.workflowSteps.isNotEmpty) ...[
        const SizedBox(height: 8),
        expenseSection(
          icon: Icons.account_tree_outlined,
          title: 'Luồng duyệt',
          color: color,
          child: _buildWorkflow(d),
        ),
      ],
      if (d.followers.isNotEmpty) ...[
        const SizedBox(height: 8),
        expenseSection(
          icon: Icons.people_outline,
          title: 'Người theo dõi',
          color: color,
          child: _buildFollowers(d),
        ),
      ],
      const SizedBox(height: 8),
      expenseSection(
        icon: Icons.list_alt_outlined,
        title: 'Hạng mục',
        color: color,
        child: _buildLineItems(d),
      ),
      const SizedBox(height: 8),
      expenseSection(
        icon: Icons.attach_file,
        title: 'Tệp đính kèm',
        color: color,
        child: _buildAttachments(d.attachments),
      ),
      CommentSection(color: color),
      const SizedBox(height: 30),
    ]));
  }

  // Banner link tới phiếu quyết toán
  Widget _buildSettlementBanner(AdvanceDetail d) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.receipt_long_outlined,
            color: Color(0xFF2563EB), size: 20),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Đã có phiếu quyết toán',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D4ED8))),
          if (d.advanceSettlementName != null)
            Text(d.advanceSettlementName!,
                style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
        ])),
        const Icon(Icons.chevron_right, color: Color(0xFF2563EB)),
      ]),
    );
  }

  Widget _buildInfoGeneral(BuildContext context, AdvanceDetail d) {
    final dept = d.departmentCode != null
        ? '${d.departmentCode} - ${d.departmentName}'
        : null;
    return Column(children: [
      expenseInfoRow('Mã phiếu', d.subId,
          copyable: true, onCopy: () => _copy(context, d.subId)),
      expenseInfoRow('Tên phiếu', d.name),
      if (d.reason != null) expenseInfoRow('Lý do tạm ứng', d.reason),
      expenseInfoRow('Tạo bởi', d.createdByUser?.fullName),
      expenseInfoRow('Chức vụ', d.createdByUser?.position),
      expenseInfoRow('Tạo lúc', formatDateTime(d.createdAt)),
      expenseInfoRow('Phòng ban', dept),
      for (final f in d.customFields)
        expenseInfoRow(f['fieldLabel'] as String? ?? '',
            f['optionLabel'] as String? ?? '—'),
    ]);
  }

  Widget _buildPaymentTo(BuildContext context, AdvanceDetail d) {
    return Column(children: [
      expenseInfoRow(
          'Thanh toán cho', d.employee?.fullName ?? d.beneficiaryName),
      expenseInfoRow('Chức vụ', d.employee?.position),
      expenseInfoRow('Tên ngân hàng', d.bankName),
      expenseInfoRow('Số tài khoản', d.accountNumber,
          copyable: d.accountNumber != null,
          onCopy: d.accountNumber != null
              ? () => _copy(context, d.accountNumber!)
              : null),
      expenseInfoRow('Người thụ hưởng', d.beneficiaryName),
    ]);
  }

  Widget _buildWorkflow(AdvanceDetail d) {
    final steps = d.workflowSteps;
    return Column(
        children: List.generate(steps.length, (i) {
      final step = steps[i];
      final isCurrent = step.order == d.currentStepOrder;
      final isApproved = step.status == 2;
      final isRejected = step.status == 3;

      final dotColor = isApproved
          ? const Color(0xFF059669)
          : isRejected
              ? const Color(0xFFDC2626)
              : isCurrent
                  ? const Color(0xFF2563EB)
                  : Colors.grey.shade300;

      return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: isCurrent ? 0.15 : 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: isCurrent ? 2 : 1),
              ),
              child: Center(
                  child: isApproved
                      ? Icon(Icons.check, size: 14, color: dotColor)
                      : isRejected
                          ? Icon(Icons.close, size: 14, color: dotColor)
                          : Text('${step.order}',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: dotColor))),
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Bước ${step.order}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCurrent ? const Color(0xFF2563EB) : null)),
                if (isCurrent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Hiện tại',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              if (step.approvers.isNotEmpty)
                for (final a in step.approvers)
                  expensePersonRow(
                      name: a.fullName,
                      position: a.position,
                      color: color,
                      avatarUrl: a.avatarUrl)
              else
                expenseEmptyHint('Chưa xác định người duyệt'),
              if (step.approvedByUser != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    const Icon(Icons.check_circle,
                        size: 13, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text('Đã duyệt bởi ${step.approvedByUser!.fullName}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF059669))),
                  ]),
                ),
              if (step.rejectedByUser != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    const Icon(Icons.cancel,
                        size: 13, color: Color(0xFFDC2626)),
                    const SizedBox(width: 4),
                    Text('Từ chối bởi ${step.rejectedByUser!.fullName}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFFDC2626))),
                  ]),
                ),
              if (step.dueAt != null)
                Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text('Hạn duyệt: ${formatDateTime(step.dueAt)}',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400))),
            ]),
          )),
        ]),
      );
    }));
  }

  Widget _buildFollowers(AdvanceDetail d) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final f in d.followers)
        Tooltip(
          message: '${f.fullName}\n${f.position ?? ''}',
          child: f.avatarUrl != null
              ? CircleAvatar(
                  radius: 20, backgroundImage: NetworkImage(f.avatarUrl!))
              : avatarCircle(name: f.fullName, radius: 20, color: color),
        ),
    ]);
  }

  Widget _buildLineItems(AdvanceDetail d) {
    if (d.lineItems.isEmpty) return expenseEmptyHint('Không có hạng mục');
    return Column(children: [
      Row(children: const [
        Expanded(
            flex: 3,
            child: Text('Hạng mục / Mã NS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
        Expanded(
            flex: 1,
            child: Text('SL',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
        Expanded(
            flex: 2,
            child: Text('Thành tiền',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
      Divider(height: 12, color: Colors.grey.shade200),
      for (final item in d.lineItems) ...[
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.itemName,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  if (item.budgetCode != null)
                    Text('${item.budgetCode} · ${item.budgetCodeName}',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500)),
                ],
              )),
          Expanded(
              flex: 1,
              child: Text('${item.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text('${formatMoney(item.baseAmount)} ₫',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500))),
        ]),
        Divider(height: 14, color: Colors.grey.shade100),
      ],
      Row(children: [
        const Expanded(
            flex: 4,
            child: Text('Tổng cộng',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        Expanded(
            flex: 2,
            child: Text('${formatMoney(d.baseTotalAmount)} ₫',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: color))),
      ]),
    ]);
  }

  Widget _buildAttachments(List<PaymentAttachment> files) {
    if (files.isEmpty) return expenseEmptyHint('Không có tệp đính kèm');
    return Column(children: [
      for (final f in files)
        Builder(builder: (_) {
          final isPdf = f.ext == 'pdf';
          final isXlsx = f.ext == 'xlsx' || f.ext == 'xls';
          final clr = isPdf
              ? const Color(0xFFDC2626)
              : isXlsx
                  ? const Color(0xFF059669)
                  : const Color(0xFF2563EB);
          final bg = isPdf
              ? const Color(0xFFFEE2E2)
              : isXlsx
                  ? const Color(0xFFD1FAE5)
                  : const Color(0xFFEFF6FF);
          final icon = isPdf
              ? Icons.picture_as_pdf
              : isXlsx
                  ? Icons.table_chart_outlined
                  : Icons.insert_drive_file_outlined;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(icon, size: 18, color: clr),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(f.fileName,
                      style: TextStyle(fontSize: 12, color: clr),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis)),
              Icon(Icons.download_outlined,
                  size: 18, color: clr.withValues(alpha: 0.6)),
            ]),
          );
        }),
    ]);
  }

  Widget _buildBottomActionBar(
      BuildContext ctx, AdvanceDetail d, AdvanceDetailProvider p) {
    if (!d.canAct) return const SizedBox.shrink();
    // final dueAt = d.currentStep?.dueAt;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        // if (dueAt != null) ...[
        //    CountdownTimer(dueAt: dueAt),
        //   const SizedBox(width: 8),
        // ],
        Expanded(
          child: ElevatedButton(
            onPressed: p.acting
                ? null
                : () => _showConfirmDialog(ctx,
                        title: 'Xác nhận duyệt',
                        message: 'Duyệt phiếu này?',
                        btnColor: const Color(0xFF059669), onConfirm: () async {
                      final ok = await p.approve(id);
                      if (ctx.mounted)
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(ok ? '✅ Đã duyệt' : '❌ Duyệt thất bại'),
                          backgroundColor:
                              ok ? const Color(0xFF059669) : Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ));
                    }),
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
                : const Text('Duyệt',
                    style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: p.acting ? null : () => _showRejectDialog(ctx, p),
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

  void _showConfirmDialog(
    BuildContext ctx, {
    required String title,
    required String message,
    required Color btnColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Hủy')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: color, foregroundColor: Colors.white),
                  child: const Text('Xác nhận'),
                ),
              ],
            ));
  }

  void _showRejectDialog(BuildContext ctx, AdvanceDetailProvider p) {
    final ctrl = TextEditingController();
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: const Text('Từ chối phiếu tạm ứng'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Vui lòng nhập lý do từ chối:'),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  maxLines: 3,
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
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content:
                            Text(ok ? '❌ Đã từ chối' : '❌ Từ chối thất bại'),
                        backgroundColor: const Color(0xFFDC2626),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white),
                  child: const Text('Từ chối'),
                ),
              ],
            ));
  }
}
