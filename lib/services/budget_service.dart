import 'package:shared_preferences/shared_preferences.dart';

class BudgetService {
  static const String budgetKey = "monthly_budget";

  static Future<void> saveBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(budgetKey, budget);
  }

  static Future<double> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(budgetKey) ?? 0;
  }
}