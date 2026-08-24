import 'package:shared_preferences/shared_preferences.dart';

class BudgetService {
  static const String budgetKey = "monthly_budget";


  static Future<bool> isBudgetExceeded(double monthlyExpense) async {
    final budget = await getBudget();

    if (budget <= 0) {
      return false;
    }

    return monthlyExpense >= budget;
  }

  static Future<void> saveBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(budgetKey, budget);
  }

  static Future<double> getBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(budgetKey) ?? 0;
  }
  static String getBudgetStatus(
      double totalExpense,
      double monthlyBudget,
      ) {
    if (monthlyBudget <= 0) {
      return "";
    }

    final percentage = (totalExpense / monthlyBudget) * 100;

    if (percentage >= 100) {
      return "🚨 Budget Exceeded!";
    }

    if (percentage >= 90) {
      return "🔴 Critical! Budget almost finished";
    }

    if (percentage >= 75) {
      return "🟠 Warning! You have used 75% of your budget";
    }

    if (percentage >= 50) {
      return "🟡 Budget usage is above 50%";
    }

    return "🟢 Budget is Healthy";
  }

}