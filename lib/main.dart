import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:apart_mate/firebase_options.dart';
import 'package:apart_mate/core/theme/app_theme.dart';
import 'package:apart_mate/core/bindings/initial_binding.dart';
import 'package:apart_mate/core/constants/app_strings.dart';
import 'package:apart_mate/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ApartMateApp());
}

class ApartMateApp extends StatelessWidget {
  const ApartMateApp({super.key});

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