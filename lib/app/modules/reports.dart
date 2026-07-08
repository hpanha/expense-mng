import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/reportController.dart';
import 'package:extend_system/app/theme/app_theme.dart';

class ReportPage extends StatelessWidget {
  ReportPage({super.key});

  final controller = Get.put(ReportController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121515) : AppTheme.backgroundTeal,
        appBar: AppBar(
          title: Text(
            "Financial Reports",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.darkTeal,
            ),
          ),
          backgroundColor: isDark ? const Color(0xFF1A1D1D) : Colors.white,
          elevation: 0.5,
          bottom: TabBar(
            indicatorColor: AppTheme.primaryTeal,
            labelColor: AppTheme.primaryTeal,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Daily"),
              Tab(text: "Weekly"),
              Tab(text: "Monthly"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReportTabContent(
              controller: controller,
              reportType: 'daily',
              title: "Daily Report",
            ),
            _ReportTabContent(
              controller: controller,
              reportType: 'weekly',
              title: "Weekly Report",
            ),
            _ReportTabContent(
              controller: controller,
              reportType: 'monthly',
              title: "Monthly Report",
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTabContent extends StatefulWidget {
  final ReportController controller;
  final String reportType;
  final String title;

  const _ReportTabContent({
    required this.controller,
    required this.reportType,
    required this.title,
  });

  @override
  State<_ReportTabContent> createState() => _ReportTabContentState();
}

class _ReportTabContentState extends State<_ReportTabContent> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    final formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    if (widget.reportType == 'daily') {
      widget.controller.getDailyReport(date: formattedDate);
    } else if (widget.reportType == 'weekly') {
      widget.controller.getWeeklyReport(date: formattedDate);
    } else {
      widget.controller.getMonthlyReport(date: formattedDate);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppTheme.primaryTeal,
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E2222),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppTheme.primaryTeal,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppTheme.darkTeal,
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadReport();
    }
  }

  String _getDateDisplayString(Map<String, dynamic>? report) {
    if (widget.reportType == 'daily') {
      return report?['date'] ?? "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    } else if (widget.reportType == 'weekly') {
      if (report != null && report['start_date'] != null && report['end_date'] != null) {
        return "${report['start_date']} to ${report['end_date']}";
      }
      return "Week of ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    } else {
      return report?['month'] ?? "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async => _loadReport(),
      color: AppTheme.primaryTeal,
      child: Obx(() {
        if (widget.controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            ),
          );
        }

        final report = widget.reportType == 'daily'
            ? widget.controller.dailyReport.value
            : widget.reportType == 'weekly'
            ? widget.controller.weeklyReport.value
            : widget.controller.monthlyReport.value;

        final income = (report?['total_income'] ?? 0).toDouble();
        final expense = (report?['total_expense'] ?? 0).toDouble();
        final balance = income - expense;
        final dateLabel = _getDateDisplayString(report);

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Date Filter Selector Card
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2222) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppTheme.lightTeal,
                        child: Icon(Icons.calendar_today_rounded, color: AppTheme.primaryTeal, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Filter Date",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppTheme.darkTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.edit_calendar_rounded, color: Colors.grey[400], size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, Color(0xFF07656A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryTeal.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "\$${balance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Net Balance",
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Income and Expense Cards
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: "Income",
                      amount: income,
                      color: Colors.green,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: "Expense",
                      amount: expense,
                      color: Colors.red,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2222) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Summary Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.darkTeal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: "Total Income",
                      value: income,
                      color: Colors.green,
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      label: "Total Expense",
                      value: expense,
                      color: Colors.red,
                    ),
                    const Divider(height: 24),
                    _DetailRow(
                      label: "Balance",
                      value: balance,
                      color: AppTheme.primaryTeal,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2222) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppTheme.darkTeal,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold
                ? (isDark ? Colors.white : AppTheme.darkTeal)
                : (isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
        ),
        Text(
          "${value >= 0 ? '' : '-'}\$${value.abs().toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
