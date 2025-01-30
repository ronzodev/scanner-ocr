
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scanner/views/signature_view.dart';

import 'barcode/home_barcode.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/main_screen.dart';

void main() async {
   
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart OCR',
      theme: AppTheme.lightTheme,
      home:  MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 