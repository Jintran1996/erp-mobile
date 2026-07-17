// lib/app_theme.dart
//
// Theme mặc định cho toàn app — không set cái này thì MaterialApp rơi về
// theme Material 3 mặc định (seed tím), khiến mọi Scaffold/Card/Button nào
// quên khai báo color riêng sẽ tự lộ ra màu hồng/tím lạ.

import 'package:flutter/material.dart';

const appPrimaryColor = Color(0xFF2563EB);
const appBackgroundColor = Color(0xFFF1F5F9);

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: appPrimaryColor,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: appBackgroundColor,
  cardTheme: const CardThemeData(
    color: Colors.white,
    elevation: 1,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: appPrimaryColor,
      foregroundColor: Colors.white,
    ),
  ),
);
