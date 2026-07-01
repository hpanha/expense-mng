
import 'categories.dart';

class Transaction {
  final int id;
  final double amount;
  final String description;
  final String date;
  final Category? category;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      description: json['description'],
      date: json['date'],
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }
}