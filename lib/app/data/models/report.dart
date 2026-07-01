

class Report {
  final String type;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final String? date;
  final String? startDate;
  final String? endDate;
  final String? month;

  Report({
    required this.type,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    this.date,
    this.startDate,
    this.endDate,
    this.month,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      type: json['report_type'],
      totalIncome: double.parse(json['total_income'].toString()),
      totalExpense: double.parse(json['total_expense'].toString()),
      balance: double.parse(json['balance'].toString()),
      date: json['date'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      month: json['month'],
    );
  }
}
