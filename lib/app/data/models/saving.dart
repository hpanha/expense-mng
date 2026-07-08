import 'saving_category.dart';

class Saving {
  final int id;
  final double amount;
  final int savingCategoryId;
  final SavingCategory? savingCategory;
  final String? createdAt;

  Saving({
    required this.id,
    required this.amount,
    required this.savingCategoryId,
    this.savingCategory,
    this.createdAt,
  });

  factory Saving.fromJson(Map<String, dynamic> json) {
    return Saving(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      amount: double.parse((json['amount'] ?? 0).toString()),
      savingCategoryId: json['saving_category_id'] is int
          ? json['saving_category_id']
          : int.parse((json['saving_category_id'] ?? 0).toString()),
      savingCategory: json['saving_category'] != null
          ? SavingCategory.fromJson(
              json['saving_category'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'saving_category_id': savingCategoryId,
      };
}
