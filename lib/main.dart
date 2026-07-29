import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RupeeLensApp());
}

class RupeeLensApp extends StatelessWidget {
  const RupeeLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RupeeLens',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: HomeScreen(),
    );
  }
}