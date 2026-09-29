import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense {

  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String paymentMethod;

  @HiveField(6)
  String denomination;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.paymentMethod,
    required this.denomination,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'denomination': denomination,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, [String? docId]) {
    return Expense(
      id: docId ?? map['id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? '',
      denomination: map['denomination'] ?? '',
    );
  }
}