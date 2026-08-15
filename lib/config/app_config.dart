// lib/config/app_config.dart

class AppConfig {
  // ── Đổi URL ở đây tùy môi trường ──────────────────────────
  //
  // DEV - Emulator Android:
  //   static const String baseUrl = 'http://10.0.2.2:7228';
  //
  // DEV - Điện thoại thật (cùng WiFi):
  //   static const String baseUrl = 'http://192.168.1.x:7228';
  //   (xem IP máy tính bằng: ipconfig / ifconfig)
  //
  // PRODUCTION:
  //static const String baseUrl = 'https://thaituangarment.com.vn/erp2025';
  //
  // ──────────────────────────────────────────────────────────

  static const String baseUrl = 'https://localhost:7228'; // ← đổi IP ở đây
  // static const String baseUrl = 'http://10.0.2.2:5202'; // ← đổi IP ở đây

  static const String hubUrl = '$baseUrl/hubs/notifications';
}
