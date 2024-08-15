import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siparis_takip/constants/AppThemes.dart';
import 'package:siparis_takip/view/base_page.dart';
import 'package:siparis_takip/view/home_page.dart';
import 'package:siparis_takip/view/splas_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isFirstRun = prefs.getBool('isFirstRun') ?? true;
  if (isFirstRun) {
    prefs.setBool('isFirstRun', false);
  }
  runApp(ProviderScope(child: Main(isFirstRun: isFirstRun,)));
}

class Main extends StatelessWidget {
  final bool isFirstRun;
  Main({required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: AppThemes.darkTheme,
      theme: AppThemes.lightTheme,
      home: isFirstRun ? const SplashPage() : BasePage(),

      routes: {
        "/home_page": (context) => HomePage(),
        "/splash_page": (context) => const SplashPage(),
      },
    );
  }
}
