import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/reportController.dart';
import 'package:extend_system/app/theme/app_theme.dart';

class ReportPage extends StatelessWidget {
  ReportPage({super.key});

  final controller = Get.put(ReportController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xffF8FAFC),
        appBar: AppBar(
          title: const Text("Financial Reports"),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: AppTheme.primaryNavy,
            unselectedLabelColor: Colors.grey,
            tabs: [
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
              title: "Today's Report",
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
  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    if (widget.reportType == 'daily') {
      widget.controller.getDailyReport();
    } else if (widget.reportType == 'weekly') {
      widget.controller.getWeeklyReport();
    } else {
      widget.controller.getMonthlyReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadReport(),
      child: Obx(() {
        if (widget.controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
            ),
          );
        }

        final report = widget.reportType == 'daily'
            ? widget.controller.dailyReport.value
            : widget.reportType == 'weekly'
            ? widget.controller.weeklyReport.value
            : widget.controller.monthlyReport.value;

        if (report == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No data available',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final income = (report['total_income'] ?? 0).toDouble();
        final expense = (report['total_expense'] ?? 0).toDouble();
        final balance = income - expense;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryNavy, const Color(0xff1e3a8a)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withOpacity(0.3),
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "\$${balance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Current Balance",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
                  const SizedBox(width: 15),
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
              const SizedBox(height: 24),

              // Summary Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Summary Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
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
                      color: AppTheme.primaryNavy,
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppTheme.primaryNavy,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppTheme.primaryNavy : Colors.grey[700],
          ),
        ),
        Text(
          "\$${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
      ],
    );
  }
}
