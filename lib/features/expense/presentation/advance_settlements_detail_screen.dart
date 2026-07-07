// lib/features/expense/settlement_detail_screen.dart
// Screen chi tiết Thanh toán tạm ứng (advance-settlements).
// Dùng SettlementDetailProvider từ payment_provider.dart.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../presentation/payment_provider.dart';
import '../../expense/data/advance_settlement_model.dart';
import '../../expense/data/payment_model.dart';
import '../../_shared/countdown_timer.dart';
import '../../_shared/ui/chips.dart';
import '../../_shared/ui/section_widgets.dart';
import '../_shared/expense_status.dart';
import '../_shared/expense_formatters.dart';
import '../../../providers/comment_provider.dart';
import '../../_shared/ui/comment_section.dart';

class AdvanceSettlementsDetailScreen extends StatelessWidget {
  final String id;
  final Color color;

  const AdvanceSettlementsDetailScreen(
      {super.key, required this.id, required this.color});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => SettlementDetailProvider()..load(id)),
        ChangeNotifierProvider(
            create: (_) => CommentProvider()
              ..init(id, 'advance-settlement')
              ..loadComments()),
      ],
      child: _SettlementDetailView(id: id, color: color),
    );
  }
}

class _SettlementDetailView extends StatelessWidget {
  final String id;
  final Color color;
  const _SettlementDetailView({required this.id, required this.color});

  void _copy(BuildContext ctx, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
      content: Text('Đã sao chép'),
      duration: Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SettlementDetailProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(context, p),
      body: p.loading
          ? Center(child: CircularProgressIndicator(color: color))
          : p.error != null
              ? _buildError(context, p)
              : p.detail == null
                  ? const SizedBox.shrink()
                  : _buildBody(context, p.detail!, p),
      bottomNavigationBar: (!p.loading && p.error == null && p.detail != null)
          ? _buildActionBar(context, p.detail!, p)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext ctx, SettlementDetailProvider p) {
    final d = p.detail;
    return AppBar(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      title: d != null
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.subId,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Row(children: [
                statusBadge(
                    label: getStatusCfg(d.status).label,
                    bg: getStatusCfg(d.status).bg,
                    fg: getStatusCfg(d.status).text,
                    fontSize: 10),
                const SizedBox(width: 8),
                Text(formatDateTime(d.createdAt),
                    style:
                        const TextStyle(fontSize: 11, color: Colors.white70)),
              ]),
            ])
          : const Text('Quyết toán tạm ứng'),
      actions: [
        IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ctx.read<SettlementDetailProvider>().load(id)),
        IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => Navigator.popUntil(ctx, (r) => r.isFirst)),
      ],
    );
  }

  Widget _buildError(BuildContext ctx, SettlementDetailProvider p) {
    return Center(
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
    ]));
  }

  Widget _buildBody(
      BuildContext ctx, SettlementDetail d, SettlementDetailProvider p) {
    return SingleChildScrollView(
        child: Column(children: [
      // 3 ô tiền
      expenseMoneyRow([
        MoneyCell(
            'Tổng QT', '${formatMoney(d.baseSettlementTotalWithTax)} ₫', color,
            large: true),
        MoneyCell('Tạm ứng gốc', '${formatMoney(d.baseTotalAdvanceAmount)} ₫',
            const Color(0xFF2563EB)),
        if (d.hasRefund)
          MoneyCell('Hoàn lại', '${formatMoney(d.refundAmount)} ₫',
              const Color(0xFF059669))
        else if (d.hasAdditional)
          MoneyCell('Chi thêm', '${formatMoney(d.additionalAmount)} ₫',
              const Color(0xFFDC2626)),
      ]),
      const SizedBox(height: 8),

      // Banner link về tạm ứng gốc
      if (d.advancePaymentId != null)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFFD97706).withValues(alpha: 0.4)),
          ),
          child: Row(children: [
            const Icon(Icons.account_balance_wallet_outlined,
                color: Color(0xFFD97706), size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Quyết toán cho phiếu tạm ứng',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E))),
                  if (d.advancePaymentName != null)
                    Text(d.advancePaymentName!,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFFD97706)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                ])),
            const Icon(Icons.chevron_right, color: Color(0xFFD97706)),
          ]),
        ),
      const SizedBox(height: 8),

      expenseSection(
          icon: Icons.info_outline,
          title: 'Thông tin chung',
          color: color,
          child: _buildInfo(ctx, d)),
      const SizedBox(height: 8),
      expenseSection(
          icon: Icons.account_balance_outlined,
          title: 'Thanh toán cho',
          color: color,
          child: _buildPayTo(ctx, d)),
      if (d.workflowSteps.isNotEmpty) ...[
        const SizedBox(height: 8),
        expenseSection(
            icon: Icons.account_tree_outlined,
            title: 'Luồng duyệt',
            color: color,
            child: _buildWorkflow(d)),
      ],
      if (d.followers.isNotEmpty) ...[
        const SizedBox(height: 8),
        expenseSection(
            icon: Icons.people_outline,
            title: 'Người theo dõi',
            color: color,
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              for (final f in d.followers)
                Tooltip(
                    message: '${f.fullName}\n${f.position ?? ''}',
                    child: f.avatarUrl != null
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(f.avatarUrl!))
                        : avatarCircle(
                            name: f.fullName, radius: 20, color: color)),
            ])),
      ],
      const SizedBox(height: 8),
      expenseSection(
          icon: Icons.list_alt_outlined,
          title: 'Hạng mục',
          color: color,
          child: _buildLineItems(d)),
      const SizedBox(height: 8),
      expenseSection(
          icon: Icons.attach_file,
          title: 'Tệp đính kèm',
          color: color,
          child: _buildAttachments(d.attachments)),
      CommentSection(color: color),
      const SizedBox(height: 30),
    ]));
  }

  Widget _buildInfo(BuildContext ctx, SettlementDetail d) {
    return Column(children: [
      expenseInfoRow('Mã phiếu', d.subId,
          copyable: true, onCopy: () => _copy(ctx, d.subId)),
      expenseInfoRow('Tên phiếu', d.name),
      if (d.description != null) expenseInfoRow('Mô tả', d.description),
      expenseInfoRow('Tạo bởi', d.createdByUser?.fullName),
      expenseInfoRow('Chức vụ', d.createdByUser?.position),
      expenseInfoRow('Tạo lúc', formatDateTime(d.createdAt)),
      expenseInfoRow('Hạn duyệt', formatDate(d.dueAt),
          valueColor: const Color(0xFFDC2626)),
    ]);
  }

  Widget _buildPayTo(BuildContext ctx, SettlementDetail d) {
    return Column(children: [
      expenseInfoRow('Nhân viên', d.employee?.fullName ?? d.beneficiaryName),
      expenseInfoRow('Chức vụ', d.employee?.position),
      expenseInfoRow('Ngân hàng', d.bankName),
      expenseInfoRow('Số tài khoản', d.accountNumber,
          copyable: d.accountNumber != null,
          onCopy: d.accountNumber != null
              ? () => _copy(ctx, d.accountNumber!)
              : null),
      expenseInfoRow('Người thụ hưởng', d.beneficiaryName),
    ]);
  }

  Widget _buildWorkflow(SettlementDetail d) {
    return Column(
        children: List.generate(d.workflowSteps.length, (i) {
      final step = d.workflowSteps[i];
      final isCurrent = step.order == d.currentStepOrder;
      final isApproved = step.status == 2;
      final isRejected = step.status == 3;
      final dotColor = isApproved
          ? const Color(0xFF059669)
          : isRejected
              ? const Color(0xFFDC2626)
              : isCurrent
                  ? color
                  : Colors.grey.shade300;

      // Bước đã xong: approvers=[] nhưng approvedByUser có data
      final displayApprovers = step.approvers.isNotEmpty
          ? step.approvers
          : step.approvedByUser != null
              ? [step.approvedByUser!]
              : <PaymentUser>[];

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
          if (i < d.workflowSteps.length - 1)
            Expanded(
                child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: dotColor.withValues(alpha: 0.3))),
        ]),
        const SizedBox(width: 10),
        Expanded(
            child: Padding(
          padding:
              EdgeInsets.only(bottom: i < d.workflowSteps.length - 1 ? 16 : 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Bước ${step.order}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCurrent ? color : null)),
              if (isCurrent) ...[
                const SizedBox(width: 8),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('Hiện tại',
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w500))),
              ],
            ]),
            const SizedBox(height: 4),
            if (displayApprovers.isNotEmpty)
              for (final a in displayApprovers)
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
                    Flexible(
                        child: Text(
                            'Đã duyệt bởi ${step.approvedByUser!.fullName}',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF059669)))),
                  ])),
            if (step.dueAt != null)
              Text('Hạn: ${formatDateTime(step.dueAt)}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ]),
        )),
      ]));
    }));
  }

  Widget _buildLineItems(SettlementDetail d) {
    if (d.lineItems.isEmpty) return expenseEmptyHint('Không có hạng mục');
    return Column(children: [
      Row(children: const [
        Expanded(
            flex: 3,
            child: Text('Hạng mục',
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
                    Row(children: [
                      Text('Đơn giá: ${formatMoney(item.unitPrice)} ₫',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: item.taxRate > 0
                              ? const Color(0xFFFEF3C7)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('VAT ${item.taxRateLabel}',
                            style: TextStyle(
                                fontSize: 9,
                                color: item.taxRate > 0
                                    ? const Color(0xFF92400E)
                                    : Colors.grey)),
                      ),
                    ]),
                  ])),
          Expanded(
              flex: 1,
              child: Text('${item.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12))),
          Expanded(
              flex: 2,
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${formatMoney(item.totalWithTax)} ₫',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500)),
                if (item.taxAmount > 0)
                  Text('Thuế: ${formatMoney(item.taxAmount)} ₫',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ])),
        ]),
        Divider(height: 14, color: Colors.grey.shade100),
      ],
      Row(children: [
        const Expanded(
            flex: 4,
            child: Text('Tổng quyết toán',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        Expanded(
            flex: 2,
            child: Text('${formatMoney(d.baseSettlementTotalWithTax)} ₫',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold, color: color))),
      ]),
      // Tóm tắt hoàn lại / chi thêm
      if (d.hasRefund || d.hasAdditional) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                d.hasRefund ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(
                d.hasRefund
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                size: 16,
                color: d.hasRefund
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626)),
            const SizedBox(width: 8),
            Text(
                d.hasRefund
                    ? 'Hoàn lại: ${formatMoney(d.refundAmount)} ₫'
                    : 'Chi thêm: ${formatMoney(d.additionalAmount)} ₫',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: d.hasRefund
                        ? const Color(0xFF059669)
                        : const Color(0xFFDC2626))),
          ]),
        ),
      ],
    ]);
  }

  Widget _buildAttachments(List<PaymentAttachment> files) {
    if (files.isEmpty) return expenseEmptyHint('Không có tệp đính kèm');
    return Column(children: [
      for (final f in files)
        Builder(builder: (_) {
          final isPdf = f.ext == 'pdf';
          final isImg = ['jpg', 'jpeg', 'png'].contains(f.ext);
          final clr = isPdf
              ? const Color(0xFFDC2626)
              : isImg
                  ? const Color(0xFF0891B2)
                  : const Color(0xFF2563EB);
          final bg = isPdf
              ? const Color(0xFFFEE2E2)
              : isImg
                  ? const Color(0xFFE0F2FE)
                  : const Color(0xFFEFF6FF);
          final icon = isPdf
              ? Icons.picture_as_pdf
              : isImg
                  ? Icons.image_outlined
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

  Widget _buildActionBar(
      BuildContext ctx, SettlementDetail d, SettlementDetailProvider p) {
    if (!d.canAct) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        //   if (d.currentStep?.dueAt != null) ...[
        //     CountdownTimer(dueAt: d.currentStep!.dueAt!),
        //     const SizedBox(width: 8),
        //  ],
        Expanded(
          child: ElevatedButton(
            onPressed: p.acting
                ? null
                : () => _showConfirm(ctx,
                        title: 'Xác nhận duyệt',
                        message: 'Duyệt phiếu quyết toán này?',
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

  void _showConfirm(BuildContext ctx,
      {required String title,
      required String message,
      required Color btnColor,
      required VoidCallback onConfirm}) {
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
                        backgroundColor: btnColor,
                        foregroundColor: Colors.white),
                    child: const Text('Xác nhận')),
              ],
            ));
  }

  void _showReject(BuildContext ctx, SettlementDetailProvider p) {
    final ctrl = TextEditingController();
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: const Text('Từ chối quyết toán'),
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
                        contentPadding: const EdgeInsets.all(10))),
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
                    if (ctx.mounted)
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content:
                            Text(ok ? '❌ Đã từ chối' : '❌ Từ chối thất bại'),
                        backgroundColor: const Color(0xFFDC2626),
                        behavior: SnackBarBehavior.floating,
                      ));
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
