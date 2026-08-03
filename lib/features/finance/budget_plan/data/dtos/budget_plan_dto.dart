// lib/features/finance/budget_plan/data/budget_plan_dto.dart
//
// DTO — dữ liệu thô từ API, map 1-1 với JSON response.
// Không chứa business logic, chỉ parse JSON.

class BudgetPlanUserDto {
  final String id;
  final String fullName;
  final String? position;
  final String? avatarUrl;

  const BudgetPlanUserDto({
    required this.id,
    required this.fullName,
    this.position,
    this.avatarUrl,
  });

  factory BudgetPlanUserDto.fromJson(Map<String, dynamic> j) =>
      BudgetPlanUserDto(
        id: j['id']?.toString() ?? '',
        fullName: j['fullName'] as String? ?? '—',
        position: j['position'] as String?,
        avatarUrl: j['avatarUrl'] as String?,
      );
}

class BudgetDepartmentDto {
  final String id;
  final String name;
  final String? code;

  const BudgetDepartmentDto({
    required this.id,
    required this.name,
    this.code,
  });

  factory BudgetDepartmentDto.fromJson(Map<String, dynamic> j) =>
      BudgetDepartmentDto(
        id: j['id']?.toString() ?? '',
        name: j['name'] as String? ?? '—',
        code: j['code'] as String?,
      );
}

class BudgetPeriodDto {
  final String id;
  final int year;
  final int month;

  const BudgetPeriodDto({
    required this.id,
    required this.year,
    required this.month,
  });

  factory BudgetPeriodDto.fromJson(Map<String, dynamic> j) => BudgetPeriodDto(
        id: j['id']?.toString() ?? '',
        year: (j['year'] as int?) ?? 0,
        month: (j['month'] as int?) ?? 0,
      );
}

class BudgetPlanDto {
  final String id;
  final String departmentId;
  final BudgetDepartmentDto? department;
  final String budgetPeriodId;
  final BudgetPeriodDto? budgetPeriod;
  final num totalAmount;
  final num usedAmount;
  final String? createdAt;
  final int status;

  // Reviewer
  final String? selectedReviewerId;
  final BudgetPlanUserDto? selectedReviewer;
  final String? reviewedAt;

  // Approver
  final String? selectedApproverId;
  final BudgetPlanUserDto? selectedApprover;
  final String? approvedAt;

  // Returned / Cancelled
  final String? returnedByUserId;
  final BudgetPlanUserDto? returnedByUser;
  final String? cancelledByUserId;
  final BudgetPlanUserDto? cancelledByUser;

  const BudgetPlanDto({
    required this.id,
    required this.departmentId,
    required this.budgetPeriodId,
    required this.totalAmount,
    required this.usedAmount,
    required this.status,
    this.department,
    this.budgetPeriod,
    this.createdAt,
    this.selectedReviewerId,
    this.selectedReviewer,
    this.reviewedAt,
    this.selectedApproverId,
    this.selectedApprover,
    this.approvedAt,
    this.returnedByUserId,
    this.returnedByUser,
    this.cancelledByUserId,
    this.cancelledByUser,
  });

  factory BudgetPlanDto.fromJson(Map<String, dynamic> j) => BudgetPlanDto(
        id: j['id']?.toString() ?? '',
        departmentId: j['departmentId']?.toString() ?? '',
        budgetPeriodId: j['budgetPeriodId']?.toString() ?? '',
        totalAmount: (j['totalAmount'] as num?) ?? 0,
        usedAmount: (j['usedAmount'] as num?) ?? 0,
        status: (j['status'] as int?) ?? 0,
        createdAt: j['createdAt'] as String?,
        department: j['department'] != null
            ? BudgetDepartmentDto.fromJson(
                j['department'] as Map<String, dynamic>)
            : null,
        budgetPeriod: j['budgetPeriod'] != null
            ? BudgetPeriodDto.fromJson(
                j['budgetPeriod'] as Map<String, dynamic>)
            : null,
        selectedReviewerId: j['selectedReviewerId'] as String?,
        selectedReviewer: j['selectedReviewer'] != null
            ? BudgetPlanUserDto.fromJson(
                j['selectedReviewer'] as Map<String, dynamic>)
            : null,
        reviewedAt: j['reviewedAt'] as String?,
        selectedApproverId: j['selectedApproverId'] as String?,
        selectedApprover: j['selectedApprover'] != null
            ? BudgetPlanUserDto.fromJson(
                j['selectedApprover'] as Map<String, dynamic>)
            : null,
        approvedAt: j['approvedAt'] as String?,
        returnedByUserId: j['returnedByUserId'] as String?,
        returnedByUser: j['returnedByUser'] != null
            ? BudgetPlanUserDto.fromJson(
                j['returnedByUser'] as Map<String, dynamic>)
            : null,
        cancelledByUserId: j['cancelledByUserId'] as String?,
        cancelledByUser: j['cancelledByUser'] != null
            ? BudgetPlanUserDto.fromJson(
                j['cancelledByUser'] as Map<String, dynamic>)
            : null,
      );
}

// ── Budget item (hạng mục ngân sách) ────────────────────────────────
class BudgetItemDto {
  final String id;
  final String? budgetCode;
  final String? budgetCodeName;
  final String? budgetGroupName;
  final num planAmount;
  final num usedAmount;
  final num spendableAmount;
  final String? note;

  const BudgetItemDto({
    required this.id,
    this.budgetCode,
    this.budgetCodeName,
    this.budgetGroupName,
    this.planAmount = 0,
    this.usedAmount = 0,
    this.spendableAmount = 0,
    this.note,
  });

  factory BudgetItemDto.fromJson(Map<String, dynamic> j) {
    final bc = j['budgetCode'] as Map<String, dynamic>?;
    final bg = j['budgetGroup'] as Map<String, dynamic>?;
    return BudgetItemDto(
      id: j['id']?.toString() ?? '',
      budgetCode: bc?['code'] as String?,
      budgetCodeName: bc?['name'] as String?,
      budgetGroupName: bg?['name'] as String?,
      planAmount: (j['amount'] as num?) ?? 0,
      usedAmount: (j['usedAmount'] as num?) ?? 0,
      spendableAmount: (j['spendableAmount'] as num?) ?? 0,
      note: j['note'] as String?,
    );
  }
}

// ── Detail DTO ────────────────────────────────────────────────────────
class BudgetPlanDetailDto extends BudgetPlanDto {
  final bool canReview;
  final bool canApprove;
  final String? returnReason;
  final String? cancelledReason;
  final String? createdByUserId;
  final BudgetPlanUserDto? createdByUser;

  final List<BudgetItemDto> items;

  const BudgetPlanDetailDto({
    required super.id,
    required super.departmentId,
    required super.budgetPeriodId,
    required super.totalAmount,
    required super.usedAmount,
    required super.status,
    // required super.createdByUserId,
    super.department,
    super.budgetPeriod,
    super.createdAt,
    super.selectedReviewerId,
    super.selectedReviewer,
    super.reviewedAt,
    super.selectedApproverId,
    super.selectedApprover,
    super.approvedAt,
    super.returnedByUserId,
    super.returnedByUser,
    super.cancelledByUserId,
    super.cancelledByUser,
    this.canReview = false,
    this.canApprove = false,
    this.returnReason,
    this.cancelledReason,
    this.createdByUserId,
    this.createdByUser,
    this.items = const [],
  });

  factory BudgetPlanDetailDto.fromJson(Map<String, dynamic> j) {
    final base = BudgetPlanDto.fromJson(j);

    return BudgetPlanDetailDto(
      id: base.id,
      departmentId: base.departmentId,
      budgetPeriodId: base.budgetPeriodId,
      totalAmount: base.totalAmount,
      usedAmount: base.usedAmount,
      status: base.status,
      // createdByUserId: j['createdByUserId'] as String,
      department: base.department,
      budgetPeriod: base.budgetPeriod,
      createdAt: base.createdAt,
      selectedReviewerId: base.selectedReviewerId,
      selectedReviewer: base.selectedReviewer,
      reviewedAt: base.reviewedAt,
      selectedApproverId: base.selectedApproverId,
      selectedApprover: base.selectedApprover,
      approvedAt: base.approvedAt,
      returnedByUserId: base.returnedByUserId,
      returnedByUser: base.returnedByUser,
      cancelledByUserId: base.cancelledByUserId,
      cancelledByUser: base.cancelledByUser,
      canReview: j['canReview'] as bool? ?? false,
      canApprove: j['canApprove'] as bool? ?? false,
      returnReason: j['returnReason'] as String?,
      cancelledReason: j['cancelledReason'] as String?,
      createdByUserId: j['createdByUserId'] as String?,
      createdByUser: j['createdByUser'] != null
          ? BudgetPlanUserDto.fromJson(
              j['createdByUser'] as Map<String, dynamic>)
          : null,
      //  createdByUser: j['createdByUser'] as String?,

      items: (j['items'] as List? ?? [])
          .map((i) => BudgetItemDto.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}
