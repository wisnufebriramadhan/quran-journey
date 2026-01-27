import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:quran_tracker/features/prayer_time/data/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:quran_tracker/features/learning/data/service_locator.dart';
import 'package:quran_tracker/features/learning/learning_page.dart';
import 'package:quran_tracker/features/quran/audio_locator.dart';
import 'package:quran_tracker/features/quran/quran_audio_handler.dart';

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

// ===== QURAN =====
import 'features/quran/presentation/mushaf_page_view.dart';

// ===== QURAN LOG =====
import 'features/quran_log/quran_log_provider.dart';
import 'features/quran_log/presentation/quran_log_page.dart';

// ===== PRAYER TIME =====
import 'features/prayer_time/prayer_time_provider.dart';
import 'features/prayer_time/presentation/prayer_time_page.dart';

// ===== SETTINGS =====
import 'features/settings/settings_provider.dart';
import 'features/settings/persentation/prayer_settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  // Initialize notification service
  await NotificationService().init();

  // Initialize service locator
  sl.init();

  // Initialize audio service
  audioHandler = await AudioService.init(
    builder: () => QuranAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.qurantracker.audio',
      androidNotificationChannelName: 'Quran Audio',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(const QuranTrackerApp());
}

class QuranTrackerApp extends StatefulWidget {
  const QuranTrackerApp({super.key});

  @override
  State<QuranTrackerApp> createState() => _QuranTrackerAppState();
}

class _QuranTrackerAppState extends State<QuranTrackerApp>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  AppLifecycleState? _lastLifecycleState;
  DateTime? _lastPausedTime;

  static const int _appKillThresholdSeconds = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      _lastPausedTime = DateTime.now();
    }

    if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }

    _lastLifecycleState = state;
  }

  void _handleAppResumed() {
    // First launch - do nothing
    if (_lastLifecycleState == null) {
      _lastLifecycleState = AppLifecycleState.resumed;
      return;
    }

    // Check if app was killed or significantly paused
    final timeSincePaused = _lastPausedTime != null
        ? DateTime.now().difference(_lastPausedTime!).inSeconds
        : 0;

    final wasKilled = _lastLifecycleState == AppLifecycleState.detached ||
        timeSincePaused > _appKillThresholdSeconds;

    if (wasKilled) {
      _resetToHome();
    }
  }

  void _resetToHome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final context = _navigatorKey.currentContext;
      if (context == null) return;

      // ignore: use_build_context_synchronously
      final currentRoute = ModalRoute.of(context)?.settings.name;

      // Skip reset if already at gate/splash
      if (currentRoute == AppRoutes.gate || currentRoute == null) {
        return;
      }

      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QuranLogProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProxyProvider<SettingsProvider, PrayerTimeProvider>(
          create: (_) => PrayerTimeProvider(),
          update: (_, settingsProvider, prayerTimeProvider) {
            prayerTimeProvider!.updateSettings(settingsProvider.settings);
            return prayerTimeProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Quran Journey',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: _navigatorKey,
        initialRoute: AppRoutes.gate,
        routes: {
          AppRoutes.gate: (_) => const AuthGate(),
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.home: (_) => const HomePage(),
          AppRoutes.quranLog: (_) => const QuranLogPage(),
          AppRoutes.prayerTime: (_) => const PrayerTimePage(),
          AppRoutes.settings: (_) => const PrayerSettingsPage(),
          AppRoutes.mushafDigital: (_) => const MushafPageView(initialPage: 1),
          AppRoutes.learning: (_) => const LearningPage(),
        },
      ),
    );
  }
}
