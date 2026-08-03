// lib/features/finance/budget_plan/data/models/budget_plan_adjustment_model.dart
//
// Model — dữ liệu đã xử lý cho UI, map từ BudgetPlanAdjustmentDto.
// Dùng chung cấu hình trạng thái (budgetPlanStatusMap) với Kế hoạch ngân sách.

import '../dtos/budget_plan_adjustment_dto.dart';
import 'budget_plan_model.dart';

class BudgetPlanAdjustmentModel {
  final String id;
  final String budgetPlanId;
  final String departmentId;
  final String? departmentName;
  final String? departmentCode;
  final int periodYear;
  final int periodMonth;
  final num totalAmount;
  final String? createdAt;
  final int status;

  const BudgetPlanAdjustmentModel({
    required this.id,
    required this.budgetPlanId,
    required this.departmentId,
    required this.periodYear,
    required this.periodMonth,
    required this.totalAmount,
    required this.status,
    this.departmentName,
    this.departmentCode,
    this.createdAt,
  });

  // ── Computed properties ──────────────────────────────────────────
  /// T7 - 2026
  String get periodLabel => 'T$periodMonth - $periodYear';

  /// Tên hiển thị: "ITC - Trung tâm tin học" hoặc chỉ id nếu null
  String get departmentDisplay {
    if (departmentCode != null && departmentName != null) {
      return '$departmentCode - $departmentName';
    }
    if (departmentName != null) return departmentName!;
    if (departmentCode != null) return departmentCode!;
    return departmentId;
  }

  BudgetPlanStatusCfg get statusCfg =>
      budgetPlanStatusMap[status] ??
      const BudgetPlanStatusCfg('Không rõ', 0xFFF1F5F9, 0xFF475569);

  // ── Map từ DTO ───────────────────────────────────────────────────
  static BudgetPlanAdjustmentModel fromDto(BudgetPlanAdjustmentDto dto) =>
      BudgetPlanAdjustmentModel(
        id: dto.id,
        budgetPlanId: dto.budgetPlanId,
        departmentId: dto.departmentId,
        departmentName: dto.department?.name,
        departmentCode: dto.department?.code,
        periodYear: dto.budgetPeriod?.year ?? 0,
        periodMonth: dto.budgetPeriod?.month ?? 0,
        totalAmount: dto.totalAmount,
        status: dto.status,
        createdAt: dto.createdAt,
      );
}

// ── Item model ────────────────────────────────────────────────────────
class BudgetAdjustmentItemModel {
  final String id;
  final String? budgetCode;
  final String? budgetCodeName;
  final num amount;
  final String? note;

  const BudgetAdjustmentItemModel({
    required this.id,
    this.budgetCode,
    this.budgetCodeName,
    this.amount = 0,
    this.note,
  });

  String get displayCode => budgetCode != null && budgetCodeName != null
      ? '$budgetCode - $budgetCodeName'
      : budgetCode ?? budgetCodeName ?? '—';

  static BudgetAdjustmentItemModel fromDto(BudgetAdjustmentItemDto dto) =>
      BudgetAdjustmentItemModel(
        id: dto.id,
        budgetCode: dto.budgetCode,
        budgetCodeName: dto.budgetCodeName,
        amount: dto.amount,
        note: dto.note,
      );
}

// ── Detail model ──────────────────────────────────────────────────────
class BudgetPlanAdjustmentDetailModel {
  final String id;
  final String departmentId;
  final String? departmentName;
  final String? departmentCode;
  final int periodYear;
  final int periodMonth;
  final int status;
  final String? reason;
  final String? createdAt;
  final BudgetPlanUser? createdByUser;

  // Luồng duyệt
  final bool canReview;
  final BudgetPlanUser? reviewer;
  final String? reviewedAt;
  final bool canApprove;
  final BudgetPlanUser? approver;
  final String? approvedAt;
  final String? returnReason;
  final BudgetPlanUser? returnedBy;

  final List<BudgetAdjustmentItemModel> items;

  const BudgetPlanAdjustmentDetailModel({
    required this.id,
    required this.departmentId,
    required this.periodYear,
    required this.periodMonth,
    required this.status,
    this.departmentName,
    this.departmentCode,
    this.reason,
    this.createdAt,
    this.createdByUser,
    this.canReview = false,
    this.reviewer,
    this.reviewedAt,
    this.canApprove = false,
    this.approver,
    this.approvedAt,
    this.returnReason,
    this.returnedBy,
    this.items = const [],
  });

  // ── Computed ─────────────────────────────────────────────────────
  /// Tổng tiền bổ sung = sum các item.amount
  num get totalAmount => items.fold(0, (sum, e) => sum + e.amount);

  String get periodLabel => 'T$periodMonth - $periodYear';

  String get departmentDisplay {
    if (departmentCode != null && departmentName != null) {
      return '$departmentCode - $departmentName';
    }
    if (departmentName != null) return departmentName!;
    if (departmentCode != null) return departmentCode!;
    return departmentId;
  }

  BudgetPlanStatusCfg get statusCfg =>
      budgetPlanStatusMap[status] ??
      const BudgetPlanStatusCfg('Không rõ', 0xFFF1F5F9, 0xFF475569);

  static BudgetPlanAdjustmentDetailModel fromDto(
          BudgetPlanAdjustmentDetailDto dto) =>
      BudgetPlanAdjustmentDetailModel(
        id: dto.id,
        departmentId: dto.departmentId,
        departmentName: dto.department?.name,
        departmentCode: dto.department?.code,
        periodYear: dto.budgetPeriod?.year ?? 0,
        periodMonth: dto.budgetPeriod?.month ?? 0,
        status: dto.status,
        reason: dto.reason,
        createdAt: dto.createdAt,
        createdByUser: BudgetPlanUser.fromDto(dto.createdByUser),
        canReview: dto.canReview,
        reviewer: BudgetPlanUser.fromDto(dto.selectedReviewer),
        reviewedAt: dto.reviewedAt,
        canApprove: dto.canApprove,
        approver: BudgetPlanUser.fromDto(dto.selectedApprover),
        approvedAt: dto.approvedAt,
        returnReason: dto.returnReason,
        returnedBy: BudgetPlanUser.fromDto(dto.returnedByUser),
        items: dto.items.map(BudgetAdjustmentItemModel.fromDto).toList(),
      );
}
