// lib/features/dyeing_report/rejection/presentation/widgets/rejections_filter_bar.dart
//
// Row filter: Date + Markets + Search + Update.
// Giữ TextEditingController cố định trong State (không tạo lại mỗi build).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../rejections_provider.dart';

class RejectionsFilterBar extends StatefulWidget {
  final Color color;
  const RejectionsFilterBar({super.key, required this.color});

  @override
  State<RejectionsFilterBar> createState() => _RejectionsFilterBarState();
}

class _RejectionsFilterBarState extends State<RejectionsFilterBar> {
  final _dateFmt = DateFormat('dd/MM/yyyy');
  late final TextEditingController _dateCtrl;

  @override
  void initState() {
    super.initState();
    final p = context.read<RejectionsProvider>();
    _dateCtrl = TextEditingController(text: _dateFmt.format(p.selectedDate));
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(RejectionsProvider p) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: p.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateCtrl.text = _dateFmt.format(picked);
      p.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<RejectionsProvider>();
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      final children = [
        _dateField(p, l10n),
        const SizedBox(width: 12, height: 12),
        _marketDropdown(p, l10n),
        const SizedBox(width: 12, height: 12),
        ElevatedButton.icon(
          onPressed: p.loading ? null : p.loadFirstPage,
          icon: const Icon(Icons.search, size: 18),
          label: Text(l10n.filterSearch),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12, height: 12),
        OutlinedButton.icon(
          onPressed: p.loading ? null : p.loadFirstPage,
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(l10n.filterUpdate),
        ),
      ];
      return isNarrow
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children)
          : Row(children: children);
    });
  }

  Widget _dateField(RejectionsProvider p, AppLocalizations l10n) {
    return SizedBox(
      width: 220,
      child: TextField(
        readOnly: true,
        onTap: () => _pickDate(p),
        controller: _dateCtrl,
        decoration: InputDecoration(
          labelText: l10n.filterDate,
          prefixIcon: const Icon(Icons.calendar_today, size: 18),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _marketDropdown(RejectionsProvider p, AppLocalizations l10n) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        initialValue: p.selectedMarket,
        decoration: InputDecoration(
          labelText: l10n.filterMarkets,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: RejectionsProvider.markets
            .map((m) => DropdownMenuItem(value: m['code'], child: Text(m['label']!)))
            .toList(),
        onChanged: (v) {
          if (v != null) p.setMarket(v);
        },
      ),
    );
  }
}
