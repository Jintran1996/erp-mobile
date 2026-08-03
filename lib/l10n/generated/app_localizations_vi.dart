// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get dyeingReportHubTitle => 'Báo cáo nhuộm';

  @override
  String get reportRejectionsTitle => 'Dashboard Hàng lỗi';

  @override
  String get reportRejectionsDesc =>
      'Theo dõi tỷ lệ Reprocess & Defect theo tháng';

  @override
  String get reportProductionTitle => 'Báo cáo sản xuất';

  @override
  String get reportProductionDesc => 'Sản lượng, hiệu suất theo dây chuyền 123';

  @override
  String get reportInventoryTitle => 'Báo cáo tồn kho';

  @override
  String get reportInventoryDesc => 'Nguyên liệu, thành phẩm tồn kho hiện tại';

  @override
  String get reportQualityTitle => 'Báo cáo chất lượng';

  @override
  String get reportQualityDesc =>
      'Tổng hợp lỗi, nguyên nhân, khu vực phát sinh';

  @override
  String reportPlaceholderBody(String title) {
    return '$title — chưa có màn hình chi tiết';
  }

  @override
  String get rejectionsNote =>
      '*LƯU Ý: Tìm theo năm, dữ liệu cập nhật theo tháng và năm. Vui lòng chọn đúng thông tin.';

  @override
  String get rejectionsListChartLabel => 'Danh sách / Biểu đồ';

  @override
  String rejectionsReprocessChartTitle(int year) {
    return '$year - Reprocess %';
  }

  @override
  String rejectionsDefectChartTitle(int year) {
    return '$year - Defect %';
  }

  @override
  String get filterSearch => 'Tìm kiếm';

  @override
  String get filterUpdate => 'Cập nhật';

  @override
  String get filterDate => 'Ngày';

  @override
  String get filterMarkets => 'Thị trường';

  @override
  String get colMonth => 'Tháng';

  @override
  String get colTotal => 'Tổng';

  @override
  String get colReprocess => 'Reprocess';

  @override
  String get colReprocessPercent => 'Reprocess %';

  @override
  String get colDefect => 'Defect';

  @override
  String get colDefectPercent => 'Defect %';
}
