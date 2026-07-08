import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/theme/app_theme.dart';
import 'package:extend_system/app/modules/incomes_page.dart';
import 'package:extend_system/app/modules/expenses_page.dart';

class CashflowPage extends StatefulWidget {
  const CashflowPage({super.key});

  @override
  State<CashflowPage> createState() => _CashflowPageState();
}

class _CashflowPageState extends State<CashflowPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundTeal,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: Container(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryTeal,
            labelColor: AppTheme.primaryTeal,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
            tabs: const [
              Tab(text: "Incomes"),
              Tab(text: "Expenses"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          IncomesPage(showFab: false),
          ExpensesPage(showFab: false),
        ],
      ),
      floatingActionButton: ExpandableFab(
        onAddIncome: () {
          Get.bottomSheet(
            const AddIncomeForm(),
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          );
        },
        onAddExpense: () {
          Get.bottomSheet(
            const AddExpenseForm(),
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          );
        },
      ),
    );
  }
}

class ExpandableFab extends StatefulWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;

  const ExpandableFab({
    super.key,
    required this.onAddIncome,
    required this.onAddExpense,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    if (!_open) return const SizedBox.shrink();
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    
    // Add Income Button (higher distance, appears at the top)
    children.add(
      _ExpandingActionButton(
        maxDistance: 140,
        progress: _expandAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2222) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "Add Income",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FloatingActionButton.small(
              heroTag: 'add_income_fab',
              onPressed: () {
                _toggle();
                widget.onAddIncome();
              },
              backgroundColor: Colors.green,
              elevation: 3,
              child: const Icon(Icons.add_circle, color: Colors.white),
            ),
          ],
        ),
      ),
    );

    // Add Expense Button (lower distance, appears in the middle)
    children.add(
      _ExpandingActionButton(
        maxDistance: 75,
        progress: _expandAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2222) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "Add Expense",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FloatingActionButton.small(
              heroTag: 'add_expense_fab',
              onPressed: () {
                _toggle();
                widget.onAddExpense();
              },
              backgroundColor: Colors.red,
              elevation: 3,
              child: const Icon(Icons.remove_circle, color: Colors.white),
            ),
          ],
        ),
      ),
    );

    return children;
  }

  Widget _buildTapToOpenFab() {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _expandAnimation.value * math.pi / 4, // 45 degrees rotation
          child: FloatingActionButton(
            heroTag: 'main_expand_fab',
            onPressed: _toggle,
            backgroundColor: AppTheme.primaryNavy,
            elevation: 4,
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}

class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final dy = progress.value * maxDistance;
        return Positioned(
          right: 8.0, // center-aligns the 40dp small FAB with the 56dp main FAB
          bottom: 8.0 + dy,
          child: Transform.scale(
            scale: progress.value,
            child: Opacity(
              opacity: progress.value,
              child: child!,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
