import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import 'expense_service.dart';

class BackupService {
  static Future<File> exportBackup() async {
    try {
      print("===== BACKUP STARTED =====");

      final expenses = ExpenseService.getExpenses();
      print("Expenses Count: ${expenses.length}");

      final data = expenses.map((e) => {
        "id": e.id,
        "amount": e.amount,
        "category": e.category,
        "paymentMethod": e.paymentMethod,
        "description": e.description,
        "denomination": e.denomination,
        "date": e.date.toIso8601String(),
      }).toList();

      print("JSON Created");

      final directory = await getApplicationDocumentsDirectory();
      print("Directory: ${directory.path}");

      final file = File("${directory.path}/rupeelens_backup.json");

      await file.writeAsString(jsonEncode(data));

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "RupeeLens Backup File",
      );

      print("Backup Saved Successfully");
      print("File Path: ${file.path}");

      return file;
    } catch (e) {
      print("BACKUP ERROR: $e");
      rethrow;
    }
  }

  static Future<void> importBackup() async {
    FilePickerResult? result =
    await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    final jsonString = await file.readAsString();

    final List<dynamic> data = jsonDecode(jsonString);

    for (final item in data) {
      ExpenseService.addExpense(
        Expense(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: item["amount"],
          category: item["category"],
          paymentMethod: item["paymentMethod"],
          description: item["description"],
          denomination: item["denomination"] ?? "",
          date: DateTime.parse(item["date"]),
        ),
      );
    }
  }
}