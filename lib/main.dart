import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_tracker/features/quran/presentation/mushaf_page_view.dart';

// ===== CORE =====
import 'core/constants/app_theme.dart';

// ===== ROUTES =====
import 'routes/app_routes.dart';
import 'routes/auth_gate.dart';

// ===== AUTH =====
import 'features/auth/auth_provider.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';

// ===== HOME =====
import 'features/home/home_page.dart';

// ===== QURAN LOG =====
import 'features/quran_log/quran_log_provider.dart';
import 'features/quran_log/presentation/quran_log_page.dart';

// ===== PRAYER TIME =====
import 'features/prayer_time/prayer_time_provider.dart';
import 'features/prayer_time/presentation/prayer_time_page.dart';

// ===== SETTINGS =====
import 'features/settings/settings_provider.dart';
import 'features/settings/persentation/prayer_settings_page.dart';

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
        // ===== AUTH =====
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        // ===== QURAN LOG =====
        ChangeNotifierProvider(
          create: (_) => QuranLogProvider(),
        ),

        // ===== SETTINGS (HARUS DULUAN) =====
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..load(),
        ),

        // ===== PRAYER TIME (DEPENDENCY KE SETTINGS) =====
        ChangeNotifierProxyProvider<SettingsProvider, PrayerTimeProvider>(
          create: (_) => PrayerTimeProvider(),
          update: (_, settingsProvider, prayerTimeProvider) {
            prayerTimeProvider!.updateSettings(
              settingsProvider.settings,
            );
            return prayerTimeProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Quran Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        /// ⛳ START POINT
        initialRoute: AppRoutes.gate,

        /// 🧭 ROUTING TANPA AUDIO (AUDIO PAKAI Navigator.push)
        routes: {
          AppRoutes.gate: (_) => const AuthGate(),
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.home: (_) => const HomePage(),
          AppRoutes.quranLog: (_) => const QuranLogPage(),
          AppRoutes.prayerTime: (_) => const PrayerTimePage(),
          AppRoutes.settings: (_) => const PrayerSettingsPage(),
          AppRoutes.mushafDigital: (context) => const MushafPageView(initialPage: 1)
        },
      ),
    );
  }
}