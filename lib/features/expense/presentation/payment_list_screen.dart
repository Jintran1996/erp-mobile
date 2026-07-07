// lib/features/expense/payment_list_screen.dart
//
// Screen chỉ lo UI: watch PaymentListProvider, gọi action, hiện dữ liệu.
// Không còn Map<String,dynamic>, không còn raw API call.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/payment_provider.dart';
import '../../expense/data/advance_model.dart';
import '../../expense/data/advance_settlement_model.dart';
import '../../expense/data/payment_model.dart';
import '../../_shared/ui/chips.dart';
import '../_shared/expense_status.dart';
import '../_shared/expense_formatters.dart';
import '../_shared/expense_filter_bar.dart';
import 'payment_detail_screen.dart';
import 'advance_payments_detail_screen.dart';
import 'advance_settlements_detail_screen.dart';

class PaymentListScreen extends StatelessWidget {
  final String title;
  final Color color;

  const PaymentListScreen({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentListProvider()..loadFirstPage(),
      child: _PaymentListView(title: title, color: color),
    );
  }
}

class _PaymentListView extends StatefulWidget {
  final String title;
  final Color color;
  const _PaymentListView({required this.title, required this.color});

  @override
  State<_PaymentListView> createState() => _PaymentListViewState();
}

class _PaymentListViewState extends State<_PaymentListView> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent * 0.85) {
      context.read<PaymentListProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _openDetail(BuildContext context, dynamic item, PaymentListProvider p) {
    final id = item is PaymentListItem
        ? item.id
        : item is AdvanceListItem
            ? item.id
            : (item as SettlementListItem).id;

    final route = item is SettlementListItem
        ? MaterialPageRoute(
            builder: (_) =>
                AdvanceSettlementsDetailScreen(id: id, color: widget.color))
        : item is AdvanceListItem
            ? MaterialPageRoute(
                builder: (_) =>
                    AdvancePaymentsDetailScreen(id: id, color: widget.color))
            : MaterialPageRoute(
                builder: (_) =>
                    PaymentDetailScreen(id: id, color: widget.color));
    Navigator.push(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PaymentListProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(context, p),
      body: Column(children: [
        // Search
        expenseSearchBox(
          controller: _searchCtrl,
          onChanged: (v) => p.setSearch(v),
          onClear: () {
            _searchCtrl.clear();
            p.setSearch('');
          },
        ),
        // Filter chips
        expenseFilterChips(
          items: defaultStatusFilters,
          activeIndex: defaultStatusFilters
              .indexWhere((f) => f.status == p.statusFilter),
          color: widget.color,
          onSelected: (i) => p.setStatusFilter(defaultStatusFilters[i].status),
        ),
        if (!p.loading) expenseResultCount(p.items.length, total: p.total),
        // List
        Expanded(child: _buildList(context, p)),
      ]),
      bottomNavigationBar: _buildBottomNav(context, p),
    );
  }

  // ── AppBar + Topbar ───────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
      BuildContext context, PaymentListProvider p) {
    return AppBar(
      title: Text(widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: widget.color,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: p.loadFirstPage),
        IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Container(
          color: widget.color,
          child: Row(children: [
            _topTabBtn(context, p, PaymentTab.following, 'Đang theo dõi'),
            _topTabBtn(
                context, p, PaymentTab.pendingApproval, 'Đến lượt duyệt'),
          ]),
        ),
      ),
    );
  }

  Widget _topTabBtn(
      BuildContext ctx, PaymentListProvider p, PaymentTab tab, String label) {
    final active = p.topTab == tab;
    return GestureDetector(
      onTap: () => p.setTopTab(tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontSize: 13,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            )),
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context, PaymentListProvider p) {
    const tabs = [
      (ExpenseType.payment, 'Thanh toán', Icons.payment_outlined),
      (ExpenseType.advance, 'Tạm ứng', Icons.account_balance_wallet_outlined),
      (
        ExpenseType.advanceSettlement,
        'TT Tạm ứng',
        Icons.receipt_long_outlined
      ),
    ];
    final idx = tabs.indexWhere((t) => t.$1 == p.bottomTab);

    return BottomNavigationBar(
      currentIndex: idx < 0 ? 0 : idx,
      selectedItemColor: widget.color,
      unselectedItemColor: Colors.grey.shade500,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (i) => p.setBottomTab(tabs[i].$1),
      items: tabs
          .map((t) => BottomNavigationBarItem(
                icon: Icon(t.$3),
                label: t.$2,
              ))
          .toList(),
    );
  }

  // ── List body ─────────────────────────────────────────────────────
  Widget _buildList(BuildContext context, PaymentListProvider p) {
    if (p.loading) {
      return Center(child: CircularProgressIndicator(color: widget.color));
    }
    if (p.error != null) {
      return expenseErrorView(message: p.error!, onRetry: p.loadFirstPage);
    }
    if (p.items.isEmpty) {
      return expenseEmptyList(isSearching: p.search.isNotEmpty);
    }

    return RefreshIndicator(
      color: widget.color,
      onRefresh: p.loadFirstPage,
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        itemCount: p.items.length + 1,
        itemBuilder: (ctx, i) {
          if (i == p.items.length) {
            return _buildFooter(p);
          }
          final item = p.items[i];
          if (item is SettlementListItem) {
            return _SettlementCard(
                item: item,
                color: widget.color,
                onTap: () => _openDetail(ctx, item, p));
          } else if (item is AdvanceListItem) {
            return _AdvanceCard(
                item: item,
                color: widget.color,
                onTap: () => _openDetail(ctx, item, p));
          } else {
            return _PaymentCard(
                item: item as PaymentListItem,
                color: widget.color,
                onTap: () => _openDetail(ctx, item, p));
          }
        },
      ),
    );
  }

  Widget _buildFooter(PaymentListProvider p) {
    if (p.loadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
            child:
                CircularProgressIndicator(color: widget.color, strokeWidth: 2)),
      );
    }
    if (!p.hasMore && p.items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
            child: Text(
          'Đã hiển thị tất cả ${p.items.length} phiếu',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        )),
      );
    }
    return const SizedBox.shrink();
  }
}

// ── Card: Thanh toán ──────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final PaymentListItem item;
  final Color color;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.item,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = getStatusCfg(item.status);
    final approverName =
        item.approvers.isNotEmpty ? item.approvers[0].fullName : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(children: [
          // Header
          _CardHeader(
            subId: item.subId,
            createdAt: item.createdAt,
            icon: Icons.description_outlined,
            color: color,
            cfg: cfg,
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: infoChip(
                  icon: Icons.payments_outlined,
                  label: 'Tổng tiền',
                  value: '${formatMoney(item.originalTotalWithTax)} ₫',
                  color: const Color(0xFF059669),
                )),
                const SizedBox(width: 8),
                Expanded(
                    child: infoChip(
                  icon: Icons.calendar_today_outlined,
                  label: 'Hạn TT',
                  value: formatDate(item.dueAt),
                  color: item.dueAt == null
                      ? Colors.grey
                      : const Color(0xFFDC2626),
                )),
              ]),
              if (item.approvers.isNotEmpty || item.createdByUser != null) ...[
                const SizedBox(height: 8),
                Row(children: [
                  if (item.approvers.isNotEmpty)
                    tagChip(
                      icon: Icons.people_outline,
                      label: item.approvers.length == 1
                          ? approverName
                          : '$approverName +${item.approvers.length - 1}',
                      bg: const Color(0xFFEFF6FF),
                      fg: const Color(0xFF1D4ED8),
                    ),
                  if (item.approvers.isNotEmpty && item.createdByUser != null)
                    const SizedBox(width: 6),
                  if (item.createdByUser != null)
                    Expanded(
                        child: tagChip(
                      icon: Icons.person_outline,
                      label: item.createdByUser!.fullName,
                      bg: const Color(0xFFF5F3FF),
                      fg: const Color(0xFF6D28D9),
                    )),
                ]),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Card: Tạm ứng ────────────────────────────────────────────────────
class _AdvanceCard extends StatelessWidget {
  final AdvanceListItem item;
  final Color color;
  final VoidCallback onTap;

  const _AdvanceCard({
    required this.item,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = getStatusCfg(item.status);
    final approverName =
        item.approvers.isNotEmpty ? item.approvers[0].fullName : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(children: [
          // Header
          _CardHeader(
            subId: item.subId,
            createdAt: item.createdAt,
            icon: Icons.account_balance_wallet_outlined,
            color: color,
            cfg: cfg,
            extraBadge: item.isForeignPayment ? 'Ngoại tệ' : null,
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              infoChip(
                icon: Icons.payments_outlined,
                label: 'Số tiền tạm ứng',
                value:
                    '${formatMoney(item.originalTotalAmount)} ${item.originalCurrencyCode}',
                color: const Color(0xFF059669),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (item.approvedByUser != null)
                  tagChip(
                    icon: Icons.check_circle_outline,
                    label: 'Đã duyệt: ${item.approvedByUser!.fullName}',
                    bg: const Color(0xFFD1FAE5),
                    fg: const Color(0xFF065F46),
                  )
                else if (item.rejectedByUser != null)
                  tagChip(
                    icon: Icons.cancel_outlined,
                    label: 'Từ chối: ${item.rejectedByUser!.fullName}',
                    bg: const Color(0xFFFEE2E2),
                    fg: const Color(0xFF991B1B),
                  )
                else if (item.approvers.isNotEmpty)
                  tagChip(
                    icon: Icons.people_outline,
                    label: item.approvers.length == 1
                        ? approverName
                        : '$approverName +${item.approvers.length - 1}',
                    bg: const Color(0xFFEFF6FF),
                    fg: const Color(0xFF1D4ED8),
                  ),
                if (item.createdByUser != null)
                  tagChip(
                    icon: Icons.person_outline,
                    label: item.createdByUser!.position?.isNotEmpty == true
                        ? '${item.createdByUser!.fullName} · ${item.createdByUser!.position}'
                        : item.createdByUser!.fullName,
                    bg: const Color(0xFFF5F3FF),
                    fg: const Color(0xFF6D28D9),
                  ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Card: Thanh toán Tạm ứng ────────────────────────────────────────────────────
class _SettlementCard extends StatelessWidget {
  final SettlementListItem item;
  final Color color;
  final VoidCallback onTap;

  const _SettlementCard({
    required this.item,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = getStatusCfg(item.status);
    final approverName =
        item.approvers.isNotEmpty ? item.approvers[0].fullName : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(children: [
          // Header
          _CardHeader(
            subId: item.subId,
            createdAt: item.createdAt,
            icon: Icons.account_balance_wallet_outlined,
            color: color,
            cfg: cfg,
            extraBadge: item.isForeignSettlement ? 'Ngoại tệ' : null,
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 10),
              infoChip(
                icon: Icons.payments_outlined,
                label: 'Số tiền thanh toán tạm ứng',
                value:
                    '${formatMoney(item.baseTotalWithTax)} ${item.originalCurrencyCode}',
                color: const Color(0xFF059669),
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (item.approvedByUser != null)
                  tagChip(
                    icon: Icons.check_circle_outline,
                    label: 'Đã duyệt: ${item.approvedByUser!.fullName}',
                    bg: const Color(0xFFD1FAE5),
                    fg: const Color(0xFF065F46),
                  )
                else if (item.rejectedByUser != null)
                  tagChip(
                    icon: Icons.cancel_outlined,
                    label: 'Từ chối: ${item.rejectedByUser!.fullName}',
                    bg: const Color(0xFFFEE2E2),
                    fg: const Color(0xFF991B1B),
                  )
                else if (item.approvers.isNotEmpty)
                  tagChip(
                    icon: Icons.people_outline,
                    label: item.approvers.length == 1
                        ? approverName
                        : '$approverName +${item.approvers.length - 1}',
                    bg: const Color(0xFFEFF6FF),
                    fg: const Color(0xFF1D4ED8),
                  ),
                if (item.createdByUser != null)
                  tagChip(
                    icon: Icons.person_outline,
                    label: item.createdByUser!.position?.isNotEmpty == true
                        ? '${item.createdByUser!.fullName} · ${item.createdByUser!.position}'
                        : item.createdByUser!.fullName,
                    bg: const Color(0xFFF5F3FF),
                    fg: const Color(0xFF6D28D9),
                  ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Shared card header ────────────────────────────────────────────────
class _CardHeader extends StatelessWidget {
  final String subId;
  final String? createdAt;
  final IconData icon;
  final Color color;
  final StatusCfg cfg;
  final String? extraBadge;

  const _CardHeader({
    required this.subId,
    required this.createdAt,
    required this.icon,
    required this.color,
    required this.cfg,
    this.extraBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(subId,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: color)),
              if (extraBadge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAEEDA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(extraBadge!,
                      style: const TextStyle(
                          fontSize: 9, color: Color(0xFF854F0B))),
                ),
              ],
            ]),
            if (createdAt != null)
              Text(formatDateTime(createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ],
        )),
        statusBadge(label: cfg.label, bg: cfg.bg, fg: cfg.text),
      ]),
    );
  }
}
