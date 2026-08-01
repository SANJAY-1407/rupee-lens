import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/expense.dart';
import 'services/theme_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Expense>('expenses');

  runApp(const RupeeLensApp());
}

class RupeeLensApp extends StatefulWidget {
  const RupeeLensApp({super.key});

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
    bool isDark = await ThemeService.loadTheme();

    themeNotifier.value =
    isDark ? ThemeMode.dark : ThemeMode.light;
  }
  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: "RupeeLens",

          theme: ThemeData(
            colorSchemeSeed: Colors.green,
            brightness: Brightness.light,
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            colorSchemeSeed: Colors.green,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),

          themeMode: currentMode,

          home: const HomeScreen(),
        );
      },
    );
  }
}