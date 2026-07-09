// lib/features/dyeing_report/rejection/data/rejection_api_service.dart
//
// Service - gọi API dashboard-report-rejections.
//
// LƯU Ý: đây là hệ thống Report API riêng, KHÔNG đi qua ApiClient (Dio)
// dùng chung của app, vì API này public (không cần Bearer token) và nằm
// trên domain khác. Base URL lấy tập trung từ AppConfig.reportApiBaseUrl
// để đổi môi trường chỉ cần sửa 1 chỗ.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'rejection_model.dart';

class RejectionsApiService {
  static const String _endpoint =
      //    '${AppConfig.reportApiBaseUrl}/api/Dashboards/dashboard-report-rejections';
      'https://thaituangarment.com.vn/ReportApi/api/Dashboards/dashboard-report-rejections';

  /// [date] dạng yyyy-MM-dd, [market] vd 'ND' hoặc 'ALL'
  Future<RejectionsResponse> fetch({
    required DateTime date,
    required String market,
  }) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'date': dateStr,
      if (market != 'ALL') 'thitruong': market,
    });

    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('Lỗi HTTP ${res.statusCode}');
    }

    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final parsed = RejectionsResponse.fromJson(body);

    if (!parsed.status) {
      throw Exception(parsed.error.isNotEmpty ? parsed.error : parsed.message);
    }
    return parsed;
  }
}
