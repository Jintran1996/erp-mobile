import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// Tiêu đề AppBar của màn hub Báo cáo nhuộm
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo nhuộm'**
  String get dyeingReportHubTitle;

  /// No description provided for @reportRejectionsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Dashboard Hàng lỗi'**
  String get reportRejectionsTitle;

  /// No description provided for @reportRejectionsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi tỷ lệ Reprocess & Defect theo tháng'**
  String get reportRejectionsDesc;

  /// No description provided for @reportProductionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo sản xuất'**
  String get reportProductionTitle;

  /// No description provided for @reportProductionDesc.
  ///
  /// In vi, this message translates to:
  /// **'Sản lượng, hiệu suất theo dây chuyền 123'**
  String get reportProductionDesc;

  /// No description provided for @reportInventoryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo tồn kho'**
  String get reportInventoryTitle;

  /// No description provided for @reportInventoryDesc.
  ///
  /// In vi, this message translates to:
  /// **'Nguyên liệu, thành phẩm tồn kho hiện tại'**
  String get reportInventoryDesc;

  /// No description provided for @reportQualityTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo chất lượng'**
  String get reportQualityTitle;

  /// No description provided for @reportQualityDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tổng hợp lỗi, nguyên nhân, khu vực phát sinh'**
  String get reportQualityDesc;

  /// Nội dung màn placeholder cho report chưa build UI
  ///
  /// In vi, this message translates to:
  /// **'{title} — chưa có màn hình chi tiết'**
  String reportPlaceholderBody(String title);

  /// No description provided for @rejectionsNote.
  ///
  /// In vi, this message translates to:
  /// **'*LƯU Ý: Tìm theo năm, dữ liệu cập nhật theo tháng và năm. Vui lòng chọn đúng thông tin.'**
  String get rejectionsNote;

  /// No description provided for @rejectionsListChartLabel.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách / Biểu đồ'**
  String get rejectionsListChartLabel;

  /// No description provided for @rejectionsReprocessChartTitle.
  ///
  /// In vi, this message translates to:
  /// **'{year} - Reprocess %'**
  String rejectionsReprocessChartTitle(int year);

  /// No description provided for @rejectionsDefectChartTitle.
  ///
  /// In vi, this message translates to:
  /// **'{year} - Defect %'**
  String rejectionsDefectChartTitle(int year);

  /// No description provided for @filterSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get filterSearch;

  /// No description provided for @filterUpdate.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật'**
  String get filterUpdate;

  /// No description provided for @filterDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get filterDate;

  /// No description provided for @filterMarkets.
  ///
  /// In vi, this message translates to:
  /// **'Thị trường'**
  String get filterMarkets;

  /// No description provided for @colMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get colMonth;

  /// No description provided for @colTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng'**
  String get colTotal;

  /// No description provided for @colReprocess.
  ///
  /// In vi, this message translates to:
  /// **'Reprocess'**
  String get colReprocess;

  /// No description provided for @colReprocessPercent.
  ///
  /// In vi, this message translates to:
  /// **'Reprocess %'**
  String get colReprocessPercent;

  /// No description provided for @colDefect.
  ///
  /// In vi, this message translates to:
  /// **'Defect'**
  String get colDefect;

  /// No description provided for @colDefectPercent.
  ///
  /// In vi, this message translates to:
  /// **'Defect %'**
  String get colDefectPercent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
