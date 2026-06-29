// lib/core/models/payment_model.dart
//
// Model cho phiếu Thanh toán (expense-payments).
// Dùng class thuần + fromJson — không cần code-gen, dễ đọc, dễ sửa.

class PaymentUser {
  final String fullName;
  final String? position;
  final String? avatarUrl;

  const PaymentUser({
    required this.fullName,
    this.position,
    this.avatarUrl,
  });

  factory PaymentUser.fromJson(Map<String, dynamic> j) => PaymentUser(
        fullName: j['fullName'] as String? ?? '—',
        position: j['position'] as String?,
        avatarUrl: j['avatarUrl'] as String?,
      );
}

// ── Step trong luồng duyệt ────────────────────────────────────────────
class WorkflowStep {
  final int order;
  final int status;
  final String? dueAt;
  final List<PaymentUser> approvers;
  final PaymentUser? approvedByUser;
  final PaymentUser? rejectedByUser;

  const WorkflowStep({
    required this.order,
    required this.status,
    this.dueAt,
    this.approvers = const [],
    this.approvedByUser,
    this.rejectedByUser,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> j) => WorkflowStep(
        order: j['order'] as int? ?? 0,
        status: j['status'] as int? ?? 0,
        dueAt: j['dueAt'] as String?,
        approvers: (j['approvers'] as List? ?? [])
            .map((a) => PaymentUser.fromJson(a as Map<String, dynamic>))
            .toList(),
        approvedByUser: j['approvedByUser'] != null
            ? PaymentUser.fromJson(j['approvedByUser'] as Map<String, dynamic>)
            : null,
        rejectedByUser: j['rejectedByUser'] != null
            ? PaymentUser.fromJson(j['rejectedByUser'] as Map<String, dynamic>)
            : null,
      );
}

// ── Hạng mục trong phiếu ─────────────────────────────────────────────
class PaymentLineItem {
  final String itemName;
  final num quantity;
  final num baseTotalWithTax;
  final num taxRate;
  final String? budgetCode;
  final String? budgetCodeName;
  final String? budgetGroupName;

  const PaymentLineItem({
    required this.itemName,
    required this.quantity,
    required this.baseTotalWithTax,
    required this.taxRate,
    this.budgetCode,
    this.budgetCodeName,
    this.budgetGroupName,
  });

  factory PaymentLineItem.fromJson(Map<String, dynamic> j) {
    final bc = j['budgetCode'] as Map<String, dynamic>?;
    final bg = j['budgetGroup'] as Map<String, dynamic>?;
    return PaymentLineItem(
      itemName: j['itemName'] as String? ?? '—',
      quantity: (j['quantity'] as num?) ?? 1,
      baseTotalWithTax: (j['baseTotalWithTax'] ?? j['baseAmount'] ?? 0) as num,
      taxRate: (j['taxRate'] as num?) ?? 0,
      budgetCode: bc?['code'] as String?,
      budgetCodeName: bc?['name'] as String?,
      budgetGroupName: bg?['name'] as String?,
    );
  }
}

// ── Tệp đính kèm ─────────────────────────────────────────────────────
class PaymentAttachment {
  final String fileName;
  final String? fileUrl;

  const PaymentAttachment({required this.fileName, this.fileUrl});

  factory PaymentAttachment.fromJson(Map<String, dynamic> j) =>
      PaymentAttachment(
        fileName: j['fileName'] as String? ?? 'File',
        fileUrl: j['fileUrl'] as String?,
      );

  String get ext => fileName.split('.').last.toLowerCase();
}

// ── List item (hiển thị trong danh sách) ─────────────────────────────
class PaymentListItem {
  final String id;
  final String subId;
  final String name;
  final int status;
  final num? originalTotalWithTax;
  final String? dueAt;
  final String? createdAt;
  final PaymentUser? createdByUser;
  final List<PaymentUser> approvers;

  const PaymentListItem({
    required this.id,
    required this.subId,
    required this.name,
    required this.status,
    this.originalTotalWithTax,
    this.dueAt,
    this.createdAt,
    this.createdByUser,
    this.approvers = const [],
  });

  factory PaymentListItem.fromJson(Map<String, dynamic> j) {
    final actor = j['currentExpenseStepInstanceActor'] as Map<String, dynamic>?;
    final approvers = (actor?['approvers'] as List? ?? [])
        .map((a) => PaymentUser.fromJson(a as Map<String, dynamic>))
        .toList();

    return PaymentListItem(
      id: j['id']?.toString() ?? '',
      subId: j['subId']?.toString() ?? '—',
      name: j['name']?.toString() ?? '—',
      status: (j['status'] as int?) ?? 0,
      originalTotalWithTax: j['originalTotalWithTax'] as num?,
      dueAt: j['dueAt'] as String?,
      createdAt: j['createdAt'] as String?,
      createdByUser: j['createdByUser'] != null
          ? PaymentUser.fromJson(j['createdByUser'] as Map<String, dynamic>)
          : null,
      approvers: approvers,
    );
  }
}

// ── Detail item (màn hình chi tiết) ──────────────────────────────────
class PaymentDetail {
  final String id;
  final String subId;
  final String name;
  final int status;
  final String? createdAt;
  final String? dueAt;

  // Tiền
  final num baseTotalWithTax;
  final num outgoingAmountApproved;
  final num remainingOutgoingAmount;

  // Người tạo & phòng ban
  final PaymentUser? createdByUser;
  final String? departmentCode;
  final String? departmentName;

  // Thanh toán cho
  final PaymentUser? employee;
  final String? bankName;
  final String? accountNumber;
  final String? beneficiaryName;
  final String? baseCurrencyCode;
  final String? supplierName;

  // Workflow
  final List<WorkflowStep> workflowSteps;
  final int currentStepOrder;
  final List<Map<String, dynamic>> customFields;

  // Nội dung
  final List<PaymentLineItem> lineItems;
  final List<PaymentAttachment> attachments;
  final List<PaymentUser> followers;

  const PaymentDetail({
    required this.id,
    required this.subId,
    required this.name,
    required this.status,
    this.createdAt,
    this.dueAt,
    this.baseTotalWithTax = 0,
    this.outgoingAmountApproved = 0,
    this.remainingOutgoingAmount = 0,
    this.createdByUser,
    this.departmentCode,
    this.departmentName,
    this.employee,
    this.bankName,
    this.accountNumber,
    this.beneficiaryName,
    this.baseCurrencyCode,
    this.supplierName,
    this.workflowSteps = const [],
    this.currentStepOrder = 1,
    this.customFields = const [],
    this.lineItems = const [],
    this.attachments = const [],
    this.followers = const [],
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> j) {
    final dept = j['department'] as Map<String, dynamic>?;
    final workflow = j['workflowInstance'] as Map<String, dynamic>?;
    final steps = (workflow?['steps'] as List? ?? [])
        .map((s) => WorkflowStep.fromJson(s as Map<String, dynamic>))
        .toList();
    final customFields =
        (workflow?['customFields'] as List? ?? []).cast<Map<String, dynamic>>();

    return PaymentDetail(
      id: j['id']?.toString() ?? '',
      subId: j['subId']?.toString() ?? '—',
      name: j['name']?.toString() ?? '—',
      status: (j['status'] as int?) ?? 0,
      createdAt: j['createdAt'] as String?,
      dueAt: j['dueAt'] as String?,
      baseTotalWithTax: (j['baseTotalWithTax'] as num?) ?? 0,
      outgoingAmountApproved: (j['outgoingAmountApproved'] as num?) ?? 0,
      remainingOutgoingAmount: (j['remainingOutgoingAmount'] as num?) ?? 0,
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
      baseCurrencyCode: j['baseCurrencyCode'] as String?,
      supplierName: j['supplierName'] as String?,
      workflowSteps: steps,
      currentStepOrder: (workflow?['currentStepOrder'] as int?) ?? 1,
      customFields: customFields,
      lineItems: (j['items'] as List? ?? [])
          .map((i) => PaymentLineItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      attachments: (j['attachments'] as List? ?? [])
          .map((a) => PaymentAttachment.fromJson(a as Map<String, dynamic>))
          .toList(),
      followers: (j['followers'] as List? ?? [])
          .map((f) => PaymentUser.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Step hiện tại trong workflow
  WorkflowStep? get currentStep => workflowSteps.isEmpty
      ? null
      : workflowSteps.cast<WorkflowStep?>().firstWhere(
            (s) => s?.order == currentStepOrder,
            orElse: () => null,
          );

  /// Có thể duyệt/từ chối không (status == 1 = Chờ duyệt)
  bool get canAct => status == 1;
}
