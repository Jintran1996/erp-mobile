import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đăng ký AuthService vào ApiClient ngay khi khởi động
  // (loadFromStorage() sẽ gọi lại registerTokenProvider,
  //  nhưng đăng ký sớm ở đây để đảm bảo không bao giờ null)
  ApiClient.instance.registerTokenProvider(AuthService.instance);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
