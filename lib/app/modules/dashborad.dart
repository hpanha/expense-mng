import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/dashboardController.dart';
import 'package:extend_system/app/data/controller/incomeController.dart';
import 'package:extend_system/app/data/controller/expenseController.dart';
import 'package:extend_system/app/data/controller/authController.dart';
import 'package:extend_system/app/data/controller/savingController.dart';
import 'package:extend_system/app/theme/app_theme.dart';
import 'package:extend_system/app/modules/incomes_page.dart';
import 'package:extend_system/app/modules/expenses_page.dart';
import 'package:extend_system/app/modules/layout.dart';
import 'package:extend_system/app/modules/profile.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final DashboardController dashboardController = Get.put(DashboardController());
  final IncomeController incomeController = Get.put(IncomeController());
  final ExpenseController expenseController = Get.put(ExpenseController());
  final SavingController savingController = Get.put(SavingController());
  final AuthController authController = Get.find<AuthController>();

  // Fetch all data
  Future<void> _refreshData() async {
    await dashboardController.loadReport();
    await incomeController.getIncome();
    await expenseController.getExpenses();
    await savingController.getSavings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Make sure we have the latest list on build
    _refreshData();

    return Scaffold(
      backgroundColor: AppTheme.backgroundTeal,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primaryTeal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Profile Row
              Obx(() {
                final userName = authController.user.value?['name'] ?? 'User';
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.to(() => const ProfilePage(), transition: Transition.rightToLeft),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.primaryTeal.withOpacity(0.15),
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkTeal,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, $userName",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkTeal,
                              ),
                            ),
                            Text(
                              "Welcome back",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.darkTeal.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: AppTheme.darkTeal,
                        size: 28,
                      ),
                      onPressed: () {
                        Get.changeThemeMode(
                          Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                        );
                      },
                    ),
                  ],
                );
              }),
              const SizedBox(height: 24),

              // 2. Teal Gradient Balance Card
              Obx(() {
                final income = dashboardController.income.value;
                final saving = savingController.totalSaved;
                final expense = dashboardController.expense.value;
                final bigTotal = income + saving;
                final todayStr = DateTime.now().toLocal().toString().split(' ')[0];

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryTeal, Color(0xFF07656A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total Funds (Income + Saving)",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "\$${bigTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCardBreakdownItem("Income", income),
                          _buildCardBreakdownItem("Saving", saving),
                          _buildCardBreakdownItem("Expense", expense, subtitle: todayStr),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 28),

              // 3. Quick Action Title & Cards
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quick Action",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.darkTeal,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_circle_outline_rounded,
                      label: "Add Income",
                      color: Colors.green,
                      onTap: () {
                        Get.bottomSheet(
                          const AddIncomeForm(),
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.remove_circle_outline_rounded,
                      label: "Add Expense",
                      color: Colors.red,
                      onTap: () {
                        Get.bottomSheet(
                          const AddExpenseForm(),
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.savings_outlined,
                      label: "Add Saving",
                      color: AppTheme.primaryTeal,
                      onTap: () {
                        try {
                          final LayoutController layoutCtrl = Get.find<LayoutController>();
                          layoutCtrl.changeTab(2);
                        } catch (e) {
                          Get.toNamed('/layout');
                          Future.delayed(const Duration(milliseconds: 100), () {
                            Get.find<LayoutController>().changeTab(2);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              // 5. Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.darkTeal,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      try {
                        final LayoutController layoutCtrl = Get.find<LayoutController>();
                        layoutCtrl.changeTab(1);
                      } catch (e) {
                        Get.toNamed('/layout');
                        Future.delayed(const Duration(milliseconds: 100), () {
                          Get.find<LayoutController>().changeTab(1);
                        });
                      }
                    },
                    child: const Text(
                      "See all",
                      style: TextStyle(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 6. Merged Transactions List
              Obx(() {
                final combined = <Map<String, dynamic>>[];

                // Add incomes
                for (var inc in incomeController.incomes) {
                  combined.add({
                    'type': 'income',
                    'title': inc.description,
                    'category': inc.category?.name ?? 'Salary',
                    'amount': inc.amount,
                    'date': inc.date,
                    'icon': Icons.arrow_downward_rounded,
                    'color': Colors.green,
                  });
                }

                // Add expenses
                for (var exp in expenseController.expenses) {
                  combined.add({
                    'type': 'expense',
                    'title': exp.description,
                    'category': exp.category?.name ?? 'Shopping',
                    'amount': exp.amount,
                    'date': exp.date,
                    'icon': Icons.arrow_upward_rounded,
                    'color': Colors.red,
                  });
                }

                // Sort by date descending
                combined.sort((a, b) => b['date'].toString().compareTo(a['date'].toString()));

                final recent = combined.take(4).toList();

                if (recent.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2222) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        "No recent transactions yet",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  itemBuilder: (context, index) {
                    final item = recent[index];
                    final isIncome = item['type'] == 'income';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2222) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: item['color'].withOpacity(0.1),
                            child: Icon(item['icon'], color: item['color'], size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.darkTeal,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item['category'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.darkTeal.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${isIncome ? '+' : '-'}\$${item['amount'].toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isIncome ? Colors.green : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "Successful", // Styled like mockup
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBreakdownItem(String label, double amount, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 8,
            ),
          ),
        ]
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2222) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.12), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.08),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppTheme.darkTeal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
