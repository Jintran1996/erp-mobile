// lib/features/finance/budget_plan/presentation/screens/budget_plan_screen.dart
//
// Màn hình danh sách Kế hoạch ngân sách — following.
// Theo ảnh: filter ngày + danh sách card.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_plan_provider.dart';
import '../../providers/budget_plan_adjustment_provider.dart';
import '../../presentation/screens/budget_plan_detail_screen.dart';
import '../../presentation/screens/budget_plan_adjustment_detail_screen.dart';
import '../widgets/budget_plan_card.dart';
import '../widgets/budget_plan_adjustment_card.dart';
import '../../../../../features/expense/_shared/expense_formatters.dart';
import '../widgets/app_tab_bar.dart';
import '../../../../../core/constants/app_module.dart';

class BudgetPlanScreen extends StatefulWidget {
  const BudgetPlanScreen({super.key});

  static const Color _color = Color(0xFF2563EB);

  @override
  State<BudgetPlanScreen> createState() => _BudgetPlanScreenState();
}

class _BudgetPlanScreenState extends State<BudgetPlanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BudgetPlanProvider()..load()),
        ChangeNotifierProvider(
            create: (_) => BudgetPlanAdjustmentProvider()..load()),
      ],
      // Builder tạo ra 1 BuildContext MỚI, nằm BÊN DƯỚI MultiProvider.
      // Bắt buộc phải có Builder này thì context.read<BudgetPlanProvider>()
      // trong nút refresh bên dưới mới tìm thấy provider — nếu dùng thẳng
      // context của build() (nằm TRÊN MultiProvider) sẽ bị lỗi:
      // "Could not find the correct Provider<BudgetPlanProvider>".
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColor.backgroundColor.value,
            // KHÔNG dùng Scaffold.appBar nữa: AppBar luôn được Scaffold vẽ
            // ĐÈ LÊN TRÊN body (paint order), nên nếu để header trong
            // appBar, tab bar nổi (nằm trong body) sẽ bị header CHE MẤT
            // thay vì đè lên header như ta muốn. Header được dựng thủ công
            // ngay trong body để ta kiểm soát đúng thứ tự vẽ: header vẽ
            // trước, tab bar (Positioned đè lên) vẽ sau => nổi lên trên.
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ⚠️ FIX quan trọng: bọc Stack trong SizedBox với chiều
                  // cao CỐ ĐỊNH = chiều cao header (82) + phần tab bar
                  // tràn xuống (22) = 104.
                  //
                  // Lý do: Stack mặc định chỉ tự co theo child KHÔNG dùng
                  // Positioned (ở đây là header, cao 82px) — vùng nhận tap
                  // (hit-test) của Stack chỉ giới hạn trong đúng kích thước
                  // đó. Phần AppTabBar tràn xuống 22px tuy VẪN HIỂN THỊ
                  // được (nhờ Clip.none) nhưng nằm NGOÀI vùng nhận tap của
                  // Stack -> bấm vào nửa dưới không có phản hồi. Cho Stack
                  // 1 chiều cao tường minh bao trọn cả phần tràn thì toàn
                  // bộ tab bar mới nhận tap đúng.
                  SizedBox(
                    height: 104,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ── Header gradient (thay cho AppBar cũ) ──────
                        Container(
                          height: 82,
                          padding: const EdgeInsets.only(left: 4, right: 16),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(255, 255, 255, 255),
                                Color.fromARGB(255, 255, 255, 255),
                                Color.fromARGB(255, 255, 255, 255),
                              ],
                            ),
                          ),
                          child: SafeArea(
                            bottom: false,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back,
                                      color: AppColor.headerTextFinance.value),
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                ),
                                Expanded(
                                  child: Text(
                                    'Ngân sách',
                                    style: TextStyle(
                                      color: AppColor.headerTextFinance.value,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.refresh,
                                      color: AppColor.headerTextFinance.value),
                                  tooltip: 'Làm mới',
                                  onPressed: () => _tabController.index == 0
                                      ? context
                                          .read<BudgetPlanProvider>()
                                          .load()
                                      : context
                                          .read<BudgetPlanAdjustmentProvider>()
                                          .load(),
                                ),
                                IconButton(
                                  icon: Icon(Icons.home_outlined,
                                      color: AppColor.headerTextFinance.value),
                                  tooltip: 'Trang chủ',
                                  onPressed: () => Navigator.popUntil(
                                      context, (r) => r.isFirst),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ── Tab bar "nổi" — bottom: 0 nay nằm TRONG vùng
                        // 104px đã khai báo ở SizedBox bên ngoài, nên toàn
                        // bộ diện tích tab bar (cả nửa dưới) đều nhận tap.
                        Positioned(
                          bottom: 0,
                          left: 16,
                          right: 16,
                          child: AppTabBar(
                            controller: _tabController,
                            tabs: const [
                              'Kế hoạch ngân sách',
                              'Bổ sung kế hoạch ngân sách',
                            ],
                            activeColor: BudgetPlanScreen._color,
                            elevated: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        _BudgetPlanView(),
                        _BudgetPlanAdjustmentView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BudgetPlanView extends StatelessWidget {
  const _BudgetPlanView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BudgetPlanProvider>();

    return Column(children: [
      // Filter bar
      _buildFilterBar(context, p),

      // Summary row
      if (!p.loading && p.items.isNotEmpty) _buildSummary(p),

      // List
      Expanded(child: _buildList(context, p)),
    ]);
  }

  // ── Filter bar ────────────────────────────────────────────────────
  Widget _buildFilterBar(BuildContext context, BudgetPlanProvider p) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(children: [
        // Từ ngày
        Expanded(
          child: _DateField(
            label: 'Từ ngày',
            date: p.fromDate,
            onPicked: (d) => context.read<BudgetPlanProvider>().setFromDate(d),
          ),
        ),
        const SizedBox(width: 12),
        // Đến ngày
        Expanded(
          child: _DateField(
            label: 'Đến ngày',
            date: p.toDate,
            onPicked: (d) => context.read<BudgetPlanProvider>().setToDate(d),
          ),
        ),
      ]),
    );
  }

  // ── Summary ───────────────────────────────────────────────────────
  Widget _buildSummary(BudgetPlanProvider p) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(children: [
        _SummaryChip(
          label: '${p.items.length} kế hoạch',
          color: BudgetPlanScreen._color,
        ),
        const SizedBox(width: 12),
        _SummaryChip(
          label: 'Tổng: ${formatMoney(p.totalBudget)} ₫',
          color: const Color(0xFF059669),
        ),
      ]),
    );
  }

  // ── List ─────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context, BudgetPlanProvider p) {
    if (p.loading) {
      return const Center(
          child: CircularProgressIndicator(color: BudgetPlanScreen._color));
    }

    if (p.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(p.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: p.load,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetPlanScreen._color,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (p.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Không có kế hoạch ngân sách',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: BudgetPlanScreen._color,
      onRefresh: p.load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: p.items.length,
        itemBuilder: (ctx, i) => BudgetPlanCard(
          index: i + 1,
          item: p.items[i],

          onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => BudgetPlanDetailScreen(
                      id: p.items[i].id))), //navigate to detail screen
        ),
      ),
    );
  }
}

// ── Tab 2: Bổ sung kế hoạch ngân sách ──────────────────────────────────
class _BudgetPlanAdjustmentView extends StatelessWidget {
  const _BudgetPlanAdjustmentView();

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BudgetPlanAdjustmentProvider>();

    return Column(children: [
      // Filter bar: Chọn năm / Chọn tháng
      _buildFilterBar(context, p),

      // Summary row
      if (!p.loading && p.items.isNotEmpty) _buildSummary(p),

      // List
      Expanded(child: _buildList(context, p)),
    ]);
  }

  // ── Filter bar ────────────────────────────────────────────────────
  Widget _buildFilterBar(BuildContext context, BudgetPlanAdjustmentProvider p) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(children: [
        Expanded(
          child: _YearMonthField(
            label: 'Chọn năm',
            value: p.year,
            options: List.generate(6, (i) => DateTime.now().year - 3 + i),
            onPicked: (y) =>
                context.read<BudgetPlanAdjustmentProvider>().setYear(y),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _YearMonthField(
            label: 'Chọn tháng',
            value: p.month,
            options: List.generate(12, (i) => i + 1),
            padMonth: true,
            onPicked: (m) =>
                context.read<BudgetPlanAdjustmentProvider>().setMonth(m),
          ),
        ),
      ]),
    );
  }

  // ── Summary ───────────────────────────────────────────────────────
  Widget _buildSummary(BudgetPlanAdjustmentProvider p) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(children: [
        _SummaryChip(
          label: '${p.items.length} bổ sung',
          color: BudgetPlanScreen._color,
        ),
        const SizedBox(width: 12),
        _SummaryChip(
          label: 'Tổng: ${formatMoney(p.totalBudget)} ₫',
          color: const Color(0xFF059669),
        ),
      ]),
    );
  }

  // ── List ─────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context, BudgetPlanAdjustmentProvider p) {
    if (p.loading) {
      return const Center(
          child: CircularProgressIndicator(color: BudgetPlanScreen._color));
    }

    if (p.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(p.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: p.load,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetPlanScreen._color,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (p.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Không có bổ sung kế hoạch ngân sách',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: BudgetPlanScreen._color,
      onRefresh: p.load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: p.items.length,
        itemBuilder: (ctx, i) => BudgetPlanAdjustmentCard(
          index: i + 1,
          item: p.items[i],
          onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) =>
                      BudgetPlanAdjustmentDetailScreen(id: p.items[i].id))),
        ),
      ),
    );
  }
}

// ── Year/Month field ─────────────────────────────────────────────────
class _YearMonthField extends StatelessWidget {
  final String label;
  final int value;
  final List<int> options;
  final bool padMonth;
  final ValueChanged<int> onPicked;

  const _YearMonthField({
    required this.label,
    required this.value,
    required this.options,
    required this.onPicked,
    this.padMonth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              size: 18, color: Colors.grey.shade500),
          items: options
              .map((o) => DropdownMenuItem(
                    value: o,
                    child: Text(padMonth ? o.toString().padLeft(2, '0') : '$o',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onPicked(v);
          },
          selectedItemBuilder: (context) => options
              .map((o) => Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label,
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade500)),
                        Text(padMonth ? o.toString().padLeft(2, '0') : '$o',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ── Date field ────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPicked;

  const _DateField({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      locale: const Locale('vi', 'VN'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2563EB),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFFF8FAFC),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            const SizedBox(height: 2),
            Row(children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(fmt.format(date),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Summary chip ──────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SummaryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }
}
