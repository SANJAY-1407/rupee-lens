import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'models/expense.dart';
import 'services/theme_service.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive
  await Hive.initFlutter();

  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Expense>('expenses');

  // Timezone
  tz.initializeTimeZones();

  // Notifications
  await NotificationService.initialize();
  await NotificationService.scheduleDailyReminder();

  // Login status
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    RupeeLensApp(
      isLoggedIn: isLoggedIn,
    ),
  );
}

class RupeeLensApp extends StatefulWidget {
  final bool isLoggedIn;

  const RupeeLensApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  State<RupeeLensApp> createState() => RupeeLensAppState();
}

class RupeeLensAppState extends State<RupeeLensApp> {
  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final bool isDark = await ThemeService.loadTheme();

    themeNotifier.value =
    isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: "RupeeLens",

          // LIGHT THEME
          theme: ThemeData(
            colorSchemeSeed: Colors.green,
            brightness: Brightness.light,
            useMaterial3: true,
          ),

          // DARK THEME
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.green,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),

          themeMode: currentMode,

          // LOGIN PERSISTENCE
          home: widget.isLoggedIn
              ? const HomeScreen()
              : const LoginScreen(),
        );
      },
    );
  }
}