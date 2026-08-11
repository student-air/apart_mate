import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apart_mate/core/theme/app_theme.dart';
import 'package:apart_mate/core/bindings/initial_binding.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/routes/app_pages.dart';

void main() {
  runApp(const apart_mateApp());
}

class apart_mateApp extends StatelessWidget {
  const apart_mateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}