import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/alarm_service.dart';
import 'screens/alarm_ringing_screen.dart';
import 'package:alarm/alarm.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// State Provider to hold SharedPreferences
// This matches the structured approach used in fina
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await NotificationService().init().timeout(const Duration(seconds: 5));
    await AlarmService().init(); // Initialize Aggressive Alarm
    
    // Listen to alarm ring events
    Alarm.ringStream.stream.listen((alarmSettings) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmRingingScreen(alarmSettings: alarmSettings),
        ),
      );
    });
  } catch (e) {
    debugPrint('Service initialization failed: $e');
  }
  
  // Initialize shared preferences
  final SharedPreferences sharedPrefs;
  try {
    sharedPrefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences initialization failed: $e');
    // We need a fallback if it fails, but getInstance rarely fails forever
    // If it does, we might want to show an error or use a mock
    return; // Or continue with a partial app
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const PaceApp(),
    ),
  );
}


class PaceApp extends ConsumerWidget {
  const PaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In the future you can read settings from shared preferences
    // final isDarkMode = ref.watch(settingsProvider).isDarkMode;

    return MaterialApp(
      title: 'Pace',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // For now we default to light or system theme
      themeMode: ThemeMode.system, 
      home: const SplashScreen(),
    );
  }
}
