// lib/core/models/advance_model.dart
//
// Model cho phiếu Tạm ứng (advance-payments).
// Khác biệt với PaymentModel:
//   - Tiền: baseTotalAmount (không có thuế)
//   - Có isForeignPayment + originalCurrencyCode
//   - Có reason (lý do tạm ứng)
//   - Có advanceSettlementId/Name → link quyết toán

import 'payment_model.dart'; // dùng lại PaymentUser, WorkflowStep, PaymentAttachment

// ── List item ─────────────────────────────────────────────────────────
class AdvanceListItem {
  final String id;
  final String subId;
  final String name;
  final int status;
  final num? originalTotalAmount;
  final String originalCurrencyCode;
  final bool isForeignPayment;
  final String? createdAt;
  final PaymentUser? createdByUser;
  final List<PaymentUser> approvers;
  final PaymentUser? approvedByUser;
  final PaymentUser? rejectedByUser;
  final String? workflowInstanceId;

  const AdvanceListItem({
    required this.id,
    required this.subId,
    required this.name,
    required this.status,
    this.originalTotalAmount,
    this.originalCurrencyCode = 'VND',
    this.isForeignPayment = false,
    this.createdAt,
    this.createdByUser,
    this.approvers = const [],
    this.approvedByUser,
    this.rejectedByUser,
    this.workflowInstanceId,
  });

  factory AdvanceListItem.fromJson(Map<String, dynamic> j) {
    final actor = j['currentExpenseStepInstanceActor'] as Map<String, dynamic>?;
    final approvers = (actor?['approvers'] as List? ?? [])
        .map((a) => PaymentUser.fromJson(a as Map<String, dynamic>))
        .toList();

    return AdvanceListItem(
      id: j['id']?.toString() ?? '',
      subId: j['subId']?.toString() ?? '—',
      name: j['name']?.toString() ?? '—',
      status: (j['status'] as int?) ?? 0,
      originalTotalAmount: j['originalTotalAmount'] as num?,
      originalCurrencyCode: j['originalCurrencyCode'] as String? ?? 'VND',
      isForeignPayment: j['isForeignPayment'] as bool? ?? false,
      createdAt: j['createdAt'] as String?,
      createdByUser: j['createdByUser'] != null
          ? PaymentUser.fromJson(j['createdByUser'] as Map<String, dynamic>)
          : null,
      approvers: approvers,
      approvedByUser: actor?['approvedByUser'] != null
          ? PaymentUser.fromJson(
              actor!['approvedByUser'] as Map<String, dynamic>)
          : null,
      rejectedByUser: actor?['rejectedByUser'] != null
          ? PaymentUser.fromJson(
              actor!['rejectedByUser'] as Map<String, dynamic>)
          : null,
      workflowInstanceId: j['workflowInstanceId'] as String?,
    );
  }
}

// ── Hạng mục tạm ứng ─────────────────────────────────────────────────
class AdvanceLineItem {
  final String itemName;
  final num quantity;
  final num baseAmount;
  final String? budgetCode;
  final String? budgetCodeName;

  const AdvanceLineItem({
    required this.itemName,
    required this.quantity,
    required this.baseAmount,
    this.budgetCode,
    this.budgetCodeName,
  });

  factory AdvanceLineItem.fromJson(Map<String, dynamic> j) {
    final bc = j['budgetCode'] as Map<String, dynamic>?;
    return AdvanceLineItem(
      itemName: j['itemName'] as String? ?? '—',
      quantity: (j['quantity'] as num?) ?? 1,
      baseAmount: (j['baseAmount'] ?? j['baseTotalAmount'] ?? 0) as num,
      budgetCode: bc?['code'] as String?,
      budgetCodeName: bc?['name'] as String?,
    );
  }
}

// ── Detail ────────────────────────────────────────────────────────────
class AdvanceDetail {
  final String id;
  final String subId;
  final String name;
  final String? reason;
  final int status;
  final String? createdAt;

  // Tiền
  final num baseTotalAmount;
  final String baseCurrencyCode;
  final bool isForeignPayment;
  final num? originalTotalAmount;
  final String originalCurrencyCode;

  // Người tạo & phòng ban
  final PaymentUser? createdByUser;
  final String? departmentCode;
  final String? departmentName;

  // Thanh toán cho
  final PaymentUser? employee;
  final String? bankName;
  final String? accountNumber;
  final String? beneficiaryName;

  // Quyết toán (null = chưa có)
  final String? advanceSettlementId;
  final String? advanceSettlementName;

  // Workflow
  final List<WorkflowStep> workflowSteps;
  final int currentStepOrder;
  final List<Map<String, dynamic>> customFields;

  // Nội dung
  final List<AdvanceLineItem> lineItems;
  final List<PaymentAttachment> attachments;
  final List<PaymentUser> followers;

  const AdvanceDetail({
    required this.id,
    required this.subId,
    required this.name,
    required this.status,
    this.reason,
    this.createdAt,
    this.baseTotalAmount = 0,
    this.baseCurrencyCode = 'VND',
    this.isForeignPayment = false,
    this.originalTotalAmount,
    this.originalCurrencyCode = 'VND',
    this.createdByUser,
    this.departmentCode,
    this.departmentName,
    this.employee,
    this.bankName,
    this.accountNumber,
    this.beneficiaryName,
    this.advanceSettlementId,
    this.advanceSettlementName,
    this.workflowSteps = const [],
    this.currentStepOrder = 1,
    this.customFields = const [],
    this.lineItems = const [],
    this.attachments = const [],
    this.followers = const [],
  });

  factory AdvanceDetail.fromJson(Map<String, dynamic> j) {
    final dept = j['department'] as Map<String, dynamic>?;
    final workflow = j['workflowInstance'] as Map<String, dynamic>?;
    final steps = (workflow?['steps'] as List? ?? [])
        .map((s) => WorkflowStep.fromJson(s as Map<String, dynamic>))
        .toList();

    // UUID rỗng = chưa có quyết toán
    final settlementId = j['advanceSettlementId'] as String?;
    final hasSettlement = settlementId != null &&
        settlementId != '00000000-0000-0000-0000-000000000000';

    return AdvanceDetail(
      id: j['id']?.toString() ?? '',
      subId: j['subId']?.toString() ?? '—',
      name: j['name']?.toString() ?? '—',
      reason: j['reason'] as String?,
      status: (j['status'] as int?) ?? 0,
      createdAt: j['createdAt'] as String?,
      baseTotalAmount: (j['baseTotalAmount'] as num?) ?? 0,
      baseCurrencyCode: j['baseCurrencyCode'] as String? ?? 'VND',
      isForeignPayment: j['isForeignPayment'] as bool? ?? false,
      originalTotalAmount: j['originalTotalAmount'] as num?,
      originalCurrencyCode: j['originalCurrencyCode'] as String? ?? 'VND',
      createdByUser: j['createdByUser'] != null
          ? PaymentUser.fromJson(j['createdByUser'] as Map<String, dynamic>)
          : null,
      departmentCode: dept?['code'] as String?,
      departmentName: dept?['name'] as String?,
      employee: j['employee'] != null
          ? PaymentUser.fromJson(j['employee'] as Map<String, dynamic>)
          : null,
      bankName: j['bankName'] as String?,
      accountNumber: j['accountNumber'] as String?,
      beneficiaryName: j['beneficiaryName'] as String?,
      advanceSettlementId: hasSettlement ? settlementId : null,
      advanceSettlementName:
          hasSettlement ? j['advanceSettlementName'] as String? : null,
      workflowSteps: steps,
      currentStepOrder: (workflow?['currentStepOrder'] as int?) ?? 1,
      customFields: (workflow?['customFields'] as List? ?? [])
          .cast<Map<String, dynamic>>(),
      lineItems: (j['items'] as List? ?? [])
          .map((i) => AdvanceLineItem.fromJson(i as Map<String, dynamic>))
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

  // Kiểm tra user hiện tại có quyền duyệt step này không
  bool canUserAct(String userId) {
    if (!canAct) return false;
    final step = currentStep;
    if (step == null) return false;
    return step.approvers.any((a) => a.id == userId);
  }

  bool get hasSettlement => advanceSettlementId != null;
}
