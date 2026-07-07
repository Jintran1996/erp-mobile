import 'payment_model.dart';

// ═══════════════════════════════════════════════════════════════════════
// SETTLEMENT MODEL (Quyết toán tạm ứng)
// Endpoint: GET /api/advance-settlements/{id}/detail
// Khác advance: thêm refundAmount, additionalAmount, baseTotalAdvanceAmount,
//               link ngược về advancePaymentId, line item có thuế chi tiết
// ═══════════════════════════════════════════════════════════════════════

// ── List item ─────────────────────────────────────────────────────────
class SettlementListItem {
  final String id;
  final String subId;
  final String name;
  final int status;
  final num? baseSettlementTotalWithTax;
  final num? baseTotalWithTax;
  final num? originalTotalAmount;
  final String originalCurrencyCode;
  final bool isForeignSettlement;
  final String? createdAt;
  final PaymentUser? createdByUser;
  final List<PaymentUser> approvers;
  final PaymentUser? approvedByUser;
  final PaymentUser? rejectedByUser;

  const SettlementListItem({
    required this.id,
    required this.subId,
    required this.name,
    required this.status,
    this.baseSettlementTotalWithTax,
    this.baseTotalWithTax,
    this.originalTotalAmount,
    this.originalCurrencyCode = 'VND',
    this.isForeignSettlement = false,
    this.createdAt,
    this.createdByUser,
    this.approvers = const [],
    this.approvedByUser,
    this.rejectedByUser,
  });

  factory SettlementListItem.fromJson(Map<String, dynamic> j) {
    final actor = j['currentExpenseStepInstanceActor'] as Map<String, dynamic>?;
    final approvers = (actor?['approvers'] as List? ?? [])
        .map((a) => PaymentUser.fromJson(a as Map<String, dynamic>))
        .toList();
    return SettlementListItem(
      id: j['id']?.toString() ?? '',
      subId: j['subId']?.toString() ?? '—',
      name: j['name']?.toString() ?? '—',
      status: (j['status'] as int?) ?? 0,
      baseSettlementTotalWithTax: j['baseSettlementTotalWithTax'] as num?,
      baseTotalWithTax: j['baseTotalWithTax'] as num?,
      createdAt: j['createdAt'] as String?,
      createdByUser: j['createdByUser'] != null
          ? PaymentUser.fromJson(j['createdByUser'] as Map<String, dynamic>)
          : null,
      approvers: approvers,
    );
  }
}

// ── Line item (có thuế chi tiết hơn advance) ──────────────────────────
class SettlementLineItem {
  final String itemName;
  final num quantity;
  final num unitPrice;
  final num actualAmount; // thành tiền trước thuế
  final num taxRate; // 0.08 = 8%
  final num taxAmount; // tiền thuế
  final num totalWithTax; // thành tiền sau thuế ← field chính
  final num baseSettlementTotalWithTax;
  final num baseTotalWithTax;
  final String? budgetCode;
  final String? budgetCodeName;
  final String? budgetGroupName;
  final String? invoiceFileId; // file hóa đơn đính kèm hạng mục

  const SettlementLineItem({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.actualAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalWithTax,
    required this.baseSettlementTotalWithTax,
    required this.baseTotalWithTax,
    this.budgetCode,
    this.budgetCodeName,
    this.budgetGroupName,
    this.invoiceFileId,
  });

  factory SettlementLineItem.fromJson(Map<String, dynamic> j) {
    final bc = j['budgetCode'] as Map<String, dynamic>?;
    final bg = j['budgetGroup'] as Map<String, dynamic>?;
    return SettlementLineItem(
      itemName: j['itemName'] as String? ?? '—',
      quantity: (j['quantity'] as num?) ?? 1,
      unitPrice: (j['unitPrice'] as num?) ?? 0,
      actualAmount: (j['actualAmount'] as num?) ?? 0,
      taxRate: (j['taxRate'] as num?) ?? 0,
      taxAmount: (j['taxAmount'] as num?) ?? 0,
      totalWithTax: (j['totalWithTax'] as num?) ?? 0,
      baseSettlementTotalWithTax:
          (j['baseSettlementTotalWithTax'] as num?) ?? 0,
      baseTotalWithTax: (j['baseTotalWithTax'] as num?) ?? 0,
      budgetCode: bc?['code'] as String?,
      budgetCodeName: bc?['name'] as String?,
      budgetGroupName: bg?['name'] as String?,
      invoiceFileId: j['invoiceFileId'] as String?,
    );
  }

  // Hiển thị thuế dạng "8%" hoặc "0%"
  String get taxRateLabel => '${(taxRate * 100).toStringAsFixed(0)}%';
}

// ── Detail ────────────────────────────────────────────────────────────
class SettlementDetail {
  final String id;
  final String subId;
  final String name;
  final String? description;
  final int status;
  final String? createdAt;
  final String? dueAt;

  // Tiền quyết toán
  final num baseSettlementTotalWithTax; // tổng QT (1,950,000)
  final num originalSettlementTotalWithTax; // tổng nguyên tệ (nếu ngoại tệ)
  final bool isForeignSettlement;
  final String originalCurrencyCode;

  // Tiền tạm ứng gốc (để so sánh)
  final num baseTotalAdvanceAmount; // tạm ứng gốc (4,150,000)
  final num refundAmount; // hoàn lại = TU - QT (2,200,000)
  final num additionalAmount; // chi thêm = QT - TU (0)

  // Link về phiếu tạm ứng gốc
  final String? advancePaymentId;
  final String? advancePaymentName;

  // Người tạo & nhân viên
  final PaymentUser? createdByUser;
  final PaymentUser? employee;
  final String? bankName;
  final String? accountNumber;
  final String? beneficiaryName;

  // Workflow
  final List<WorkflowStep> workflowSteps;
  final int currentStepOrder;
  final List<Map<String, dynamic>> customFields;

  // Nội dung
  final List<SettlementLineItem> lineItems;
  final List<PaymentAttachment> attachments;
  final List<PaymentUser> followers;

  const SettlementDetail({
    required this.id,
    required this.subId,
    required this.name,
    required this.status,
    this.description,
    this.createdAt,
    this.dueAt,
    this.baseSettlementTotalWithTax = 0,
    this.originalSettlementTotalWithTax = 0,
    this.isForeignSettlement = false,
    this.originalCurrencyCode = 'VND',
    this.baseTotalAdvanceAmount = 0,
    this.refundAmount = 0,
    this.additionalAmount = 0,
    this.advancePaymentId,
    this.advancePaymentName,
    this.createdByUser,
    this.employee,
    this.bankName,
    this.accountNumber,
    this.beneficiaryName,
    this.workflowSteps = const [],
    this.currentStepOrder = 1,
    this.customFields = const [],
    this.lineItems = const [],
    this.attachments = const [],
    this.followers = const [],
  });

  factory SettlementDetail.fromJson(Map<String, dynamic> j) {
    final workflow = j['workflowInstance'] as Map<String, dynamic>?;
    final steps = (workflow?['steps'] as List? ?? [])
        .map((s) => WorkflowStep.fromJson(s as Map<String, dynamic>))
        .toList();

    return SettlementDetail(
      id: j['id']?.toString() ?? '',
      subId: j['subId']?.toString() ?? '—',
      name: j['name']?.toString() ?? '—',
      description: j['description'] as String?,
      status: (j['status'] as int?) ?? 0,
      createdAt: j['createdAt'] as String?,
      dueAt: j['dueAt'] as String?,

      baseSettlementTotalWithTax:
          (j['baseSettlementTotalWithTax'] as num?) ?? 0,
      originalSettlementTotalWithTax:
          (j['originalSettlementTotalWithTax'] as num?) ?? 0,
      isForeignSettlement:
          j['isForeignSettlemnt'] as bool? ?? false, // typo từ backend
      originalCurrencyCode:
          j['originalSettlementCurrencyCode']?.toString() ?? 'VND',

      baseTotalAdvanceAmount: (j['baseTotalAdvanceAmount'] as num?) ?? 0,
      refundAmount: (j['refundAmount'] as num?) ?? 0,
      additionalAmount: (j['additionalAmount'] as num?) ?? 0,

      advancePaymentId: j['advancePaymentId'] as String?,
      advancePaymentName: j['advancePaymentName'] as String?,

      createdByUser: j['createdByUser'] != null
          ? PaymentUser.fromJson(j['createdByUser'] as Map<String, dynamic>)
          : null,
      employee: j['employee'] != null
          ? PaymentUser.fromJson(j['employee'] as Map<String, dynamic>)
          : null,
      bankName: j['bankName'] as String?,
      accountNumber: j['accountNumber'] as String?,
      beneficiaryName: j['beneficiaryName'] as String?,

      workflowSteps: steps,
      currentStepOrder: (workflow?['currentStepOrder'] as int?) ?? 1,
      customFields: (workflow?['customFields'] as List? ?? [])
          .cast<Map<String, dynamic>>(),

      lineItems: (j['items'] as List? ?? [])
          .map((i) => SettlementLineItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      attachments: (j['attachments'] as List? ?? [])
          .map((a) => PaymentAttachment.fromJson(a as Map<String, dynamic>))
          .toList(),
      followers: (j['followers'] as List? ?? [])
          .map((f) => PaymentUser.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  WorkflowStep? get currentStep => workflowSteps.isEmpty
      ? null
      : workflowSteps.cast<WorkflowStep?>().firstWhere(
            (s) => s?.order == currentStepOrder,
            orElse: () => null,
          );

  bool get canAct => status == 1;

  // Dương = hoàn lại, Âm = chi thêm
  bool get hasRefund => refundAmount > 0;
  bool get hasAdditional => additionalAmount > 0;
}
