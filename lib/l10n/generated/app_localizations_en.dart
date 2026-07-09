// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dyeingReportHubTitle => 'Dyeing Report';

  @override
  String get reportRejectionsTitle => 'Rejections Dashboard';

  @override
  String get reportRejectionsDesc => 'Track monthly Reprocess & Defect rate';

  @override
  String get reportProductionTitle => 'Production Report';

  @override
  String get reportProductionDesc =>
      'Output & efficiency by production line 123';

  @override
  String get reportInventoryTitle => 'Inventory Report';

  @override
  String get reportInventoryDesc =>
      'Current raw material & finished goods inventory';

  @override
  String get reportQualityTitle => 'Quality Report';

  @override
  String get reportQualityDesc => 'Summary of defects, causes, and locations';

  @override
  String reportPlaceholderBody(String title) {
    return '$title — detail screen not available yet';
  }

  @override
  String get rejectionsNote =>
      '*NOTE: Search by year, data updated by month and year. Please select the correct information.';

  @override
  String get rejectionsListChartLabel => 'List / Chart';

  @override
  String rejectionsReprocessChartTitle(int year) {
    return '$year - Reprocess %';
  }

  @override
  String rejectionsDefectChartTitle(int year) {
    return '$year - Defect %';
  }

  @override
  String get filterSearch => 'Search';

  @override
  String get filterUpdate => 'Update';

  @override
  String get filterDate => 'Date';

  @override
  String get filterMarkets => 'Markets';

  @override
  String get colMonth => 'Month';

  @override
  String get colTotal => 'Total';

  @override
  String get colReprocess => 'Reprocess';

  @override
  String get colReprocessPercent => 'Reprocess %';

  @override
  String get colDefect => 'Defect';

  @override
  String get colDefectPercent => 'Defect %';
}
