// lib/screens/settings_screen.dart
//
// Màn Cài đặt: hiện tại chỉ có mục chọn ngôn ngữ (vi/en).
// Lựa chọn được lưu qua LocaleProvider (shared_preferences) và áp dụng
// ngay cho MaterialApp — các màn hình khác sẽ dịch dần theo languageCode.
//
// LanguageSettingsCard được tách riêng để dùng lại ở cả 2 nơi:
//  - SettingsScreen: full-page (mở từ lưới AppMini, có AppBar riêng)
//  - HomeScreen: nhúng trực tiếp vào tab "Cài đặt" ở bottom nav

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/_shared/app_mini_base.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const _color = Color(0xFF6366F1);

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppMiniBase(
      title: 'Cài đặt',
      color: _color,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [LanguageSettingsCard()],
      ),
    );
  }
}

class LanguageSettingsCard extends StatelessWidget {
  static const _color = Color(0xFF6366F1);

  const LanguageSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            'Ngôn ngữ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        _buildLanguageCard(context),
      ],
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    final current = context.watch<LocaleProvider>().languageCode;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLanguageTile(
            context,
            code: 'vi',
            flag: '🇻🇳',
            label: 'Tiếng Việt',
            selected: current == 'vi',
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          _buildLanguageTile(
            context,
            code: 'en',
            flag: '🇬🇧',
            label: 'English',
            selected: current == 'en',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String code,
    required String flag,
    required String label,
    required bool selected,
  }) {
    return InkWell(
      onTap: () => context.read<LocaleProvider>().setLocale(code),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: _color, size: 20)
            else
              Icon(Icons.circle_outlined,
                  color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}
