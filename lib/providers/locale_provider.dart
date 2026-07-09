// lib/providers/locale_provider.dart
//
// Lưu & phát ngôn ngữ đang chọn (vi/en) cho toàn app qua shared_preferences.
// Các màn hình muốn dịch text sẽ đọc LocaleProvider.languageCode dần về sau.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale';
  static const supportedLocales = AppLocalizations.supportedLocales;

  Locale _locale = const Locale('vi');
  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && supportedLocales.any((l) => l.languageCode == code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode == _locale.languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, languageCode);
  }
}
