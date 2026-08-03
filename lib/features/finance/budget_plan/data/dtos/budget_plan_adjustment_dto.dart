// lib/features/finance/budget_plan/data/dtos/budget_plan_adjustment_dto.dart
//
// DTO — dữ liệu thô từ API GET /api/budget-plan-adjustments/following
// Map 1-1 với JSON response, không chứa business logic.

import 'budget_plan_dto.dart';

class BudgetPlanAdjustmentDto {
  final String id;
  final String budgetPlanId;
  final String departmentId;
  final BudgetDepartmentDto? department;
  final String budgetPeriodId;
  final BudgetPeriodDto? budgetPeriod;
  final num totalAmount;
  final String? createdAt;
  final int status;

  const BudgetPlanAdjustmentDto({
    required this.id,
    required this.budgetPlanId,
    required this.departmentId,
    required this.budgetPeriodId,
    required this.totalAmount,
    required this.status,
    this.department,
    this.budgetPeriod,
    this.createdAt,
  });

  factory BudgetPlanAdjustmentDto.fromJson(Map<String, dynamic> j) =>
      BudgetPlanAdjustmentDto(
        id: j['id']?.toString() ?? '',
        budgetPlanId: j['budgetPlanId']?.toString() ?? '',
        departmentId: j['departmentId']?.toString() ?? '',
        budgetPeriodId: j['budgetPeriodId']?.toString() ?? '',
        totalAmount: (j['totalAmount'] as num?) ?? 0,
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
      );
}

// ── Item bổ sung (hạng mục ngân sách bổ sung) ──────────────────────────
class BudgetAdjustmentItemDto {
  final String id;
  final String? budgetCode;
  final String? budgetCodeName;
  final num amount;
  final String? note;

  const BudgetAdjustmentItemDto({
    required this.id,
    this.budgetCode,
    this.budgetCodeName,
    this.amount = 0,
    this.note,
  });

  factory BudgetAdjustmentItemDto.fromJson(Map<String, dynamic> j) {
    final bc = j['budgetCode'] as Map<String, dynamic>?;
    return BudgetAdjustmentItemDto(
      id: j['id']?.toString() ?? '',
      budgetCode: bc?['code'] as String?,
      budgetCodeName: bc?['name'] as String?,
      amount: (j['amount'] as num?) ?? 0,
      note: j['note'] as String?,
    );
  }
}

// ── Detail DTO — GET /api/budget-plan-adjustments/{id}/detail ───────────
class BudgetPlanAdjustmentDetailDto {
  final String id;
  final String budgetPeriodId;
  final BudgetPeriodDto? budgetPeriod;
  final String departmentId;
  final BudgetDepartmentDto? department;
  final int status;
  final String? reason;
  final String? createdAt;
  final String? createdByUserId;
  final BudgetPlanUserDto? createdByUser;

  // Luồng duyệt
  final bool canReview;
  final String? selectedReviewerId;
  final BudgetPlanUserDto? selectedReviewer;
  final String? reviewedAt;

  final bool canApprove;
  final String? selectedApproverId;
  final BudgetPlanUserDto? selectedApprover;
  final String? approvedAt;

  final String? returnReason;
  final String? returnedByUserId;
  final BudgetPlanUserDto? returnedByUser;

  final List<BudgetAdjustmentItemDto> items;

  const BudgetPlanAdjustmentDetailDto({
    required this.id,
    required this.budgetPeriodId,
    required this.departmentId,
    required this.status,
    this.budgetPeriod,
    this.department,
    this.reason,
    this.createdAt,
    this.createdByUserId,
    this.createdByUser,
    this.canReview = false,
    this.selectedReviewerId,
    this.selectedReviewer,
    this.reviewedAt,
    this.canApprove = false,
    this.selectedApproverId,
    this.selectedApprover,
    this.approvedAt,
    this.returnReason,
    this.returnedByUserId,
    this.returnedByUser,
    this.items = const [],
  });

  factory BudgetPlanAdjustmentDetailDto.fromJson(Map<String, dynamic> j) =>
      BudgetPlanAdjustmentDetailDto(
        id: j['id']?.toString() ?? '',
        budgetPeriodId: j['budgetPeriodId']?.toString() ?? '',
        departmentId: j['departmentId']?.toString() ?? '',
        status: (j['status'] as int?) ?? 0,
        reason: j['reason'] as String?,
        createdAt: j['createdAt'] as String?,
        createdByUserId: j['createdByUserId'] as String?,
        budgetPeriod: j['budgetPeriod'] != null
            ? BudgetPeriodDto.fromJson(
                j['budgetPeriod'] as Map<String, dynamic>)
            : null,
        department: j['department'] != null
            ? BudgetDepartmentDto.fromJson(
                j['department'] as Map<String, dynamic>)
            : null,
        createdByUser: j['createdByUser'] != null
            ? BudgetPlanUserDto.fromJson(
                j['createdByUser'] as Map<String, dynamic>)
            : null,
        canReview: j['canReview'] as bool? ?? false,
        selectedReviewerId: j['selectedReviewerId'] as String?,
        selectedReviewer: j['selectedReviewer'] != null
            ? BudgetPlanUserDto.fromJson(
                j['selectedReviewer'] as Map<String, dynamic>)
            : null,
        reviewedAt: j['reviewedAt'] as String?,
        canApprove: j['canApprove'] as bool? ?? false,
        selectedApproverId: j['selectedApproverId'] as String?,
        selectedApprover: j['selectedApprover'] != null
            ? BudgetPlanUserDto.fromJson(
                j['selectedApprover'] as Map<String, dynamic>)
            : null,
        approvedAt: j['approvedAt'] as String?,
        returnReason: j['returnReason'] as String?,
        returnedByUserId: j['returnedByUserId'] as String?,
        returnedByUser: j['returnedByUser'] != null
            ? BudgetPlanUserDto.fromJson(
                j['returnedByUser'] as Map<String, dynamic>)
            : null,
        items: (j['items'] as List? ?? [])
            .map((i) =>
                BudgetAdjustmentItemDto.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}
