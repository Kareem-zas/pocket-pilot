import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pockect_pilot/view/splash_view.dart';
import 'package:pockect_pilot/view/login_view.dart';
import 'package:pockect_pilot/view/home_page.dart';
import 'package:pockect_pilot/utils/notification_helper.dart';
import 'package:pockect_pilot/services/geo_reminder_service.dart';
import 'package:pockect_pilot/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();
  await GeoReminderService.initTracking();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pocket Pilot',
      themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        primaryColor: const Color(0xFF0055D4),
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE2E8F0),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1E293B)),
          bodyMedium: TextStyle(color: Color(0xFF475569)),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: const Color(0xFF3B82F6),
        cardColor: const Color(0xFF1E293B),
        dividerColor: const Color(0xFF334155),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
      home: const SplashView(),
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
