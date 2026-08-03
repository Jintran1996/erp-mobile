// lib/features/finance/budget_plan/presentation/widgets/budget_plan_card.dart
//
// Card hiển thị 1 kế hoạch ngân sách trong danh sách.
// Theo ảnh: STT | Phòng ban | Kỳ NS | Tổng tiền | Luồng duyệt | Trạng thái | Ngày tạo

import 'package:flutter/material.dart';
import '../../data/models/budget_plan_model.dart';
import '../../../../../features/expense/_shared/expense_formatters.dart';

class BudgetPlanCard extends StatelessWidget {
  final int index;
  final BudgetPlanModel item;
  final VoidCallback? onTap;

  const BudgetPlanCard({
    super.key,
    required this.index,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = item.statusCfg;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE2E8F0), // Màu xám nhẹ tinh tế
            width: 1.0, // Độ dày nét viền mảnh
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── STT ───────────────────────────────────────────────
              SizedBox(
                width: 28,
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // ── Nội dung chính ────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phòng ban
                    Text(
                      item.departmentDisplay,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Row: Kỳ NS + Tổng tiền
                    Row(children: [
                      // Kỳ ngân sách
                      _InfoChip(
                        icon: Icons.calendar_month_outlined,
                        label: item.periodLabel,
                        color: const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 8),
                      // Tổng tiền
                      _InfoChip(
                        icon: Icons.payments_outlined,
                        label: '${formatMoney(item.totalAmount)} ₫',
                        color: const Color(0xFF059669),
                      ),
                    ]),
                    const SizedBox(height: 8),

                    // Row: Luồng duyệt + Trạng thái + Ngày tạo
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar luồng duyệt
                        _ApprovalFlow(item: item),
                        const Spacer(),

                        // Trạng thái
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(cfg.bg),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cfg.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(cfg.text),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Ngày tạo
                        Text(
                          formatDate(item.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Arrow ─────────────────────────────────────────────
              if (onTap != null)
                Icon(Icons.chevron_right,
                    color: Colors.grey.shade300, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar luồng duyệt ────────────────────────────────────────────────
// Hiển thị avatar reviewer + approver theo ảnh
class _ApprovalFlow extends StatelessWidget {
  final BudgetPlanModel item;
  const _ApprovalFlow({required this.item});

  @override
  Widget build(BuildContext context) {
    final users = [
      if (item.reviewer != null) item.reviewer!,
      if (item.approver != null) item.approver!,
      if (item.returnedBy != null) item.returnedBy!,
      if (item.cancelledBy != null) item.cancelledBy!,
    ];

    if (users.isEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child:
            Icon(Icons.person_outline, size: 16, color: Colors.grey.shade400),
      );
    }

    // Stack avatars (tối đa 2)
    return SizedBox(
      width: users.length > 1 ? 50 : 32,
      height: 32,
      child: Stack(
        children: [
          for (int i = 0; i < users.length && i < 2; i++)
            Positioned(
              left: i * 18.0,
              child: _UserAvatar(user: users[i], size: 32),
            ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final BudgetPlanUser user;
  final double size;
  const _UserAvatar({required this.user, required this.size});

  @override
  Widget build(BuildContext context) {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(user.avatarUrl!),
        backgroundColor: Colors.grey.shade100,
      );
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
      child: Text(
        user.initials,
        style: TextStyle(
          fontSize: size * 0.3,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2563EB),
        ),
      ),
    );
  }
}

// ── Info chip nhỏ ─────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}
