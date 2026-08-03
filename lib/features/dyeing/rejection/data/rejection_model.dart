// lib/features/dyeing_report/rejection/data/rejection_model.dart
//
// Model - map đúng field JSON API trả về từ dashboard-report-rejections.

class RejectionMonthData {
  final int thang;
  final double totalMet;
  final double rejected;
  final double recycling;
  final double tyLeDefect;
  final double tyLeReprocess;

  const RejectionMonthData({
    required this.thang,
    required this.totalMet,
    required this.rejected,
    required this.recycling,
    required this.tyLeDefect,
    required this.tyLeReprocess,
  });

  factory RejectionMonthData.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
    return RejectionMonthData(
      thang: json['thang'] as int? ?? 0,
      totalMet: d(json['totaL_MET']),
      rejected: d(json['rejected']),
      recycling: d(json['recycling']),
      tyLeDefect: d(json['tylE_DEFECT']),
      tyLeReprocess: d(json['tylE_REPROCESS']),
    );
  }

  String get monthLabel => 'Tháng $thang';
}

class RejectionsResponse {
  final bool status;
  final String message;
  final String error;
  final List<RejectionMonthData> data;

  const RejectionsResponse({
    required this.status,
    required this.message,
    required this.error,
    required this.data,
  });

  factory RejectionsResponse.fromJson(Map<String, dynamic> json) {
    return RejectionsResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      error: json['error'] as String? ?? '',
      data: ((json['data'] as List?) ?? [])
          .map((e) => RejectionMonthData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
