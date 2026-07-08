import 'purpose.dart';

class SavingCategory {
  final int id;
  final String name;
  final double goalAmount;
  final double currentAmount;
  final int duration;
  final String unit;        // e.g. "Years", "Months"
  final String frequency;   // e.g. "Monthly", "Weekly"
  final int? purposeId;
  final Purpose? purpose;

  SavingCategory({
    required this.id,
    required this.name,
    required this.goalAmount,
    required this.currentAmount,
    required this.duration,
    required this.unit,
    required this.frequency,
    this.purposeId,
    this.purpose,
  });

  double get progressPercentage =>
      goalAmount > 0 ? (currentAmount / goalAmount).clamp(0.0, 1.0) : 0.0;

  factory SavingCategory.fromJson(Map<String, dynamic> json) {
    return SavingCategory(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      goalAmount: double.parse((json['goal_amount'] ?? 0).toString()),
      currentAmount: double.parse((json['current_amount'] ?? 0).toString()),
      duration: json['duration'] is int
          ? json['duration']
          : int.parse((json['duration'] ?? 0).toString()),
      unit: json['unit'] ?? 'Months',
      frequency: json['frequency'] ?? 'Monthly',
      purposeId: json['purpose_id'] != null
          ? int.parse(json['purpose_id'].toString())
          : null,
      purpose: json['purpose'] != null
          ? Purpose.fromJson(json['purpose'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'goal_amount': goalAmount,
        'current_amount': currentAmount,
        'duration': duration,
        'unit': unit,
        'frequency': frequency,
        if (purposeId != null) 'purpose_id': purposeId,
      };
}
