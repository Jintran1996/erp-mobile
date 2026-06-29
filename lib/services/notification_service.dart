// lib/services/notification_service.dart

import 'package:signalr_netcore/signalr_client.dart';
import 'auth_service.dart'; // ← AuthService thay cho ApiService
import '../config/app_config.dart';

class NotificationService {
  static const String hubUrl = AppConfig.hubUrl;
  late HubConnection _hub;
  Function(Map<String, dynamic>)? onNotification;

  Future<void> connect() async {
    _hub = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            // Lấy token từ AuthService.instance
            accessTokenFactory: () async => AuthService.instance.token,
          ),
        )
        .withAutomaticReconnect()
        .build();

    _hub.on('ReceiveNotification', (args) {
      if (args != null && args.isNotEmpty) {
        onNotification?.call(args[0] as Map<String, dynamic>);
      }
    });

    await _hub.start();
  }

  Future<void> disconnect() async => await _hub.stop();
}
