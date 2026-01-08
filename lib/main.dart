import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_tracker/features/auth/presentation/register_page.dart';
import 'package:quran_tracker/features/prayer_time/prayer_time_provider.dart';
import 'package:quran_tracker/features/settings/persentation/prayer_settings_page.dart';
import 'package:quran_tracker/features/settings/settings_provider.dart';

import 'core/constants/app_theme.dart';
import 'routes/app_routes.dart';
import 'routes/auth_gate.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/home/home_page.dart';
import 'features/quran_log/quran_log_provider.dart';
import 'features/quran_log/presentation/quran_log_page.dart';
import 'features/prayer_time/presentation/prayer_time_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuranTrackerApp());
}

class QuranTrackerApp extends StatelessWidget {
  const QuranTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuranLogProvider()),

        // ✅ SETTINGS HARUS DULUAN
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..load(),
        ),

        // ✅ PrayerTime tergantung Settings
        ChangeNotifierProxyProvider<SettingsProvider, PrayerTimeProvider>(
          create: (_) => PrayerTimeProvider(),
          update: (_, settingsProvider, prayerTimeProvider) {
            prayerTimeProvider!.updateSettings(settingsProvider.settings);
            return prayerTimeProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Quran Tracker',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.gate,
        routes: {
          AppRoutes.gate: (_) => const AuthGate(),
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.home: (_) => const HomePage(),
          AppRoutes.quranLog: (_) => const QuranLogPage(),
          AppRoutes.prayerTime: (_) => const PrayerTimePage(),
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.settings: (_) => const PrayerSettingsPage(),
        },
      ),
    );
  }
}
