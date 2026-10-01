import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';

import 'models/expense.dart';
import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'services/expense_service.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive
  await Hive.initFlutter();

  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Expense>('expenses');

  // Timezone
  tz.initializeTimeZones();

  // Notifications
  await NotificationService.initialize();
  await NotificationService.scheduleDailyReminder();

  runApp(const RupeeLensApp());
}

class RupeeLensApp extends StatefulWidget {
  const RupeeLensApp({super.key});

  @override
  State<RupeeLensApp> createState() => RupeeLensAppState();
}

class RupeeLensAppState extends State<RupeeLensApp> {
  String? syncedUserId;

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

  Future<void> initializeCloudSync(String uid) async {
    if (syncedUserId == uid) {
      return;
    }

    syncedUserId = uid;

    // Start listening for cloud changes
    ExpenseService.initFirestoreListener();

    // Upload existing local expenses to Firestore
    await ExpenseService.syncLocalToCloud();
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

          // FIREBASE AUTH PERSISTENCE
          home: SplashScreen(
            child: StreamBuilder<User?>(
              stream: AuthService.authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  final user = snapshot.data!;

                  initializeCloudSync(user.uid);

                  return const HomeScreen();
                }

                syncedUserId = null;

                return const LoginScreen();
              },
            ),
          ),
        );
      },
    );
  }
}
