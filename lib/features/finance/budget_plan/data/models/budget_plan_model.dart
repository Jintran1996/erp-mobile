// lib/features/finance/budget_plan/data/budget_plan_model.dart
//
// Model — dữ liệu đã xử lý cho UI.
// Được map từ DTO bởi Repository.
// Chứa computed properties (remainingAmount, periodLabel, v.v.)

import '../dtos/budget_plan_dto.dart';

// ── Status config ─────────────────────────────────────────────────────
// Theo JSON: 0=Nháp, 1=Chờ xem xét, 2=Đã duyệt, 3=Trả lại, 4=Đã hủy
// Nhìn ảnh: "Chờ xem xét" màu vàng
class BudgetPlanStatusCfg {
  final String label;
  final int bg; // Color value
  final int text; // Color value

  const BudgetPlanStatusCfg(this.label, this.bg, this.text);
}

const Map<int, BudgetPlanStatusCfg> budgetPlanStatusMap = {
  0: BudgetPlanStatusCfg('Chờ xem xét', 0xFFFEF3C7, 0xFF92400E),
  1: BudgetPlanStatusCfg('Đã xem xét', 0xFFDBEAFE, 0xFF1D4ED8),
  2: BudgetPlanStatusCfg('Đã duyệt', 0xFFD1FAE5, 0xFF065F46),
  3: BudgetPlanStatusCfg('Trả lại', 0xFFFEE2E2, 0xFF991B1B),
  4: BudgetPlanStatusCfg('Đã hủy', 0xFFF3F4F6, 0xFF6B7280),
};

// ── User model ────────────────────────────────────────────────────────
class BudgetPlanUser {
  final String id;
  final String fullName;
  final String? position;
  final String? avatarUrl;

  const BudgetPlanUser({
    required this.id,
    required this.fullName,
    this.position,
    this.avatarUrl,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    return parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';
  }

  static BudgetPlanUser? fromDto(BudgetPlanUserDto? dto) {
    if (dto == null) return null;
    return BudgetPlanUser(
      id: dto.id,
      fullName: dto.fullName,
      position: dto.position,
      avatarUrl: dto.avatarUrl,
    );
  }
}

// ── Main model ────────────────────────────────────────────────────────
class BudgetPlanModel {
  final String id;
  final String departmentId;
  final String? departmentName;
  final String? departmentCode; // vd: ITC, SR.VIL...
  final int periodYear;
  final int periodMonth;
  final num totalAmount;
  final num usedAmount;
  final String? createdAt;

  final int status;

  // Luồng duyệt
  final BudgetPlanUser? reviewer; // người xem xét
  final String? reviewedAt;
  final BudgetPlanUser? approver; // người phê duyệt
  final String? approvedAt;
  final BudgetPlanUser? returnedBy;
  final BudgetPlanUser? cancelledBy;

  const BudgetPlanModel({
    required this.id,
    required this.departmentId,
    required this.periodYear,
    required this.periodMonth,
    required this.totalAmount,
    required this.usedAmount,
    required this.status,
    this.departmentName,
    this.departmentCode,
    this.createdAt,
    this.reviewer,
    this.reviewedAt,
    this.approver,
    this.approvedAt,
    this.returnedBy,
    this.cancelledBy,
  });

  // ── Computed properties ──────────────────────────────────────────
  num get remainingAmount => totalAmount - usedAmount;
  num get usagePercent =>
      totalAmount > 0 ? (usedAmount / totalAmount * 100) : 0;

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
  static BudgetPlanModel fromDto(BudgetPlanDto dto) => BudgetPlanModel(
        id: dto.id,
        departmentId: dto.departmentId,
        departmentName: dto.department?.name,
        departmentCode: dto.department?.code,
        periodYear: dto.budgetPeriod?.year ?? 0,
        periodMonth: dto.budgetPeriod?.month ?? 0,
        totalAmount: dto.totalAmount,
        usedAmount: dto.usedAmount,
        status: dto.status,
        createdAt: dto.createdAt,
        reviewer: BudgetPlanUser.fromDto(dto.selectedReviewer),
        reviewedAt: dto.reviewedAt,
        approver: BudgetPlanUser.fromDto(dto.selectedApprover),
        approvedAt: dto.approvedAt,
        returnedBy: BudgetPlanUser.fromDto(dto.returnedByUser),
        cancelledBy: BudgetPlanUser.fromDto(dto.cancelledByUser),
      );
}

// ── Budget item model ─────────────────────────────────────────────────
class BudgetItemModel {
  final String id;
  final String? budgetCode;
  final String? budgetCodeName;
  final String? budgetGroupName;
  final num planAmount;
  final num usedAmount;
  final String? note;

  const BudgetItemModel({
    required this.id,
    this.budgetCode,
    this.budgetCodeName,
    this.budgetGroupName,
    this.planAmount = 0,
    this.usedAmount = 0,
    this.note,
  });

  num get remainingAmount => planAmount - usedAmount;

  String get displayCode => budgetCode != null && budgetCodeName != null
      ? '$budgetCode - $budgetCodeName'
      : budgetCode ?? budgetCodeName ?? '—';

  static BudgetItemModel fromDto(BudgetItemDto dto) => BudgetItemModel(
        id: dto.id,
        budgetCode: dto.budgetCode,
        budgetCodeName: dto.budgetCodeName,
        budgetGroupName: dto.budgetGroupName,
        planAmount: dto.planAmount,
        usedAmount: dto.usedAmount,
        note: dto.note,
      );
}

// ── Detail model ─────────────────────────────────────────────────────
class BudgetPlanDetailModel extends BudgetPlanModel {
  final bool canReview;
  final bool canApprove;
  final String? returnReason;
  final String? cancelledReason;
  final String? createdByUserId;
  final BudgetPlanUser? createdByUser;
  //  cancelledBy: BudgetPlanUser.fromDto(dto.cancelledByUser),
  // final String? createdByUser;
  final List<BudgetItemModel> items;

  const BudgetPlanDetailModel({
    required super.id,
    required super.departmentId,
    required super.periodYear,
    required super.periodMonth,
    required super.totalAmount,
    required super.usedAmount,
    required super.status,
    // required super.createdByUserId,
    super.departmentName,
    super.departmentCode,
    super.createdAt,
    super.reviewer,
    super.reviewedAt,
    super.approver,
    super.approvedAt,
    super.returnedBy,
    super.cancelledBy,
    this.canReview = false,
    this.canApprove = false,
    this.returnReason,
    this.createdByUserId,
    this.createdByUser,
    this.cancelledReason,
    this.items = const [],
  });

  static BudgetPlanDetailModel fromDto(BudgetPlanDetailDto dto) =>
      BudgetPlanDetailModel(
        id: dto.id,
        departmentId: dto.departmentId,
        departmentName: dto.department?.name,
        departmentCode: dto.department?.code,
        periodYear: dto.budgetPeriod?.year ?? 0,
        periodMonth: dto.budgetPeriod?.month ?? 0,
        totalAmount: dto.totalAmount,
        usedAmount: dto.usedAmount,
        status: dto.status,
        createdAt: dto.createdAt,
        reviewer: BudgetPlanUser.fromDto(dto.selectedReviewer),
        reviewedAt: dto.reviewedAt,
        approver: BudgetPlanUser.fromDto(dto.selectedApprover),
        approvedAt: dto.approvedAt,
        returnedBy: BudgetPlanUser.fromDto(dto.returnedByUser),
        cancelledBy: BudgetPlanUser.fromDto(dto.cancelledByUser),
        canReview: dto.canReview,
        canApprove: dto.canApprove,
        returnReason: dto.returnReason,
        createdByUserId: dto.createdByUserId,
        createdByUser: BudgetPlanUser.fromDto(dto.createdByUser),
        cancelledReason: dto.cancelledReason,
        items: dto.items.map(BudgetItemModel.fromDto).toList(),
      );
}
