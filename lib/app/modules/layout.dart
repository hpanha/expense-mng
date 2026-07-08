import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/theme/app_theme.dart';

import 'dashborad.dart';
import 'cashflow_page.dart';
import 'saving_goal_page.dart';
import 'settings_page.dart';
import 'reports.dart';

class LayoutController extends GetxController {
  var index = 0.obs;

  void changeTab(int i) {
    index.value = i;
  }
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final LayoutController layoutController = Get.put(LayoutController());
    final List<Widget> pages = [
      DashboardPage(),
      const CashflowPage(),
      const SavingGoalPage(),
      ReportPage(),
      const SettingsPage(),
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.backgroundTeal,
      body: SafeArea(
        child: Obx(() => pages[layoutController.index.value]),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.grey[900]! : Colors.transparent,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Obx(
            () => BottomNavigationBar(
              currentIndex: layoutController.index.value,
              onTap: layoutController.changeTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: isDark ? Colors.black : Colors.white,
              selectedItemColor: AppTheme.primaryTeal,
              unselectedItemColor: Colors.grey[500],
              selectedFontSize: 12,
              unselectedFontSize: 11,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money),
                  activeIcon: Icon(Icons.attach_money_rounded),
                  label: "Cashflow",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.savings_outlined),
                  activeIcon: Icon(Icons.savings),
                  label: "Saving",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: "Report",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: "Setting",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
