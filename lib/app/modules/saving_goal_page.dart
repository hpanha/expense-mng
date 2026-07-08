import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/theme/app_theme.dart';
import 'package:extend_system/app/data/controller/savingCategoryController.dart';
import 'package:extend_system/app/data/controller/savingController.dart';
import 'package:extend_system/app/data/controller/purposeController.dart';

class SavingGoalPage extends StatelessWidget {
  const SavingGoalPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final savingCatCtrl = Get.put(SavingCategoryController());
    final savingCtrl = Get.put(SavingController());
    final purposeCtrl = Get.put(PurposeController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundTeal,
      appBar: AppBar(
        title: const Text('Saving Goals'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.darkTeal,
      ),
      body: Obx(() {
        if (savingCatCtrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
            ),
          );
        }

        final goals = savingCatCtrl.savingCategories;

        return RefreshIndicator(
          onRefresh: () async {
            await savingCatCtrl.getSavingCategories();
            await savingCtrl.getSavings();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryNavy, Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Target",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "\$${goals.fold(0.0, (sum, g) => sum + g.goalAmount).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.savings,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Active Goals",
                      style: TextStyle(
                        color: AppTheme.primaryNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddGoalDialog(context, purposeCtrl, savingCatCtrl),
                      icon: const Icon(Icons.add, color: AppTheme.primaryNavy),
                      label: const Text(
                        "New Goal",
                        style: TextStyle(color: AppTheme.primaryNavy),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                
                if (goals.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.flag_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            "No active saving goals",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...goals.map((goal) => _buildGoalCard(context, goal, savingCtrl, savingCatCtrl)).toList(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGoalCard(
    BuildContext context, 
    dynamic goal, 
    SavingController savingCtrl,
    SavingCategoryController savingCatCtrl,
  ) {
    // Current amount from backend saving-category is goal.currentAmount
    // but the savings transactions might not be reflecting there if backend is broken.
    // For now we trust goal.currentAmount.
    final double percentage = goal.progressPercentage;
    final color = _getColorForPercentage(percentage);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2222) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.track_changes, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    Text(
                      goal.purpose?.name ?? 'No Purpose',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Add Funds'),
                    onTap: () => Future.delayed(
                      Duration.zero, 
                      () => _showAddFundsDialog(context, goal, savingCtrl, savingCatCtrl),
                    ),
                  ),
                  PopupMenuItem(
                    child: const Text('Delete Goal', style: TextStyle(color: Colors.red)),
                    onTap: () => Future.delayed(
                      Duration.zero, 
                      () => savingCatCtrl.deleteSavingCategory(goal.id),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${goal.currentAmount.toStringAsFixed(2)} saved",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.primaryNavy,
                ),
              ),
              Text(
                "Target: \$${goal.goalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForPercentage(double percentage) {
    if (percentage < 0.3) return Colors.red;
    if (percentage < 0.7) return Colors.orange;
    return Colors.green;
  }

  void _showAddGoalDialog(
    BuildContext context, 
    PurposeController purposeCtrl,
    SavingCategoryController savingCatCtrl,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final goalAmountController = TextEditingController();
    final durationController = TextEditingController(text: '1');
    String selectedUnit = 'Years';
    String selectedFrequency = 'Monthly';
    int? selectedPurposeId;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Saving Goal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Goal Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: goalAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Target Amount (\$)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Duration',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: selectedUnit,
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Days', child: Text('Days')),
                            DropdownMenuItem(value: 'Weeks', child: Text('Weeks')),
                            DropdownMenuItem(value: 'Months', child: Text('Months')),
                            DropdownMenuItem(value: 'Years', child: Text('Years')),
                          ],
                          onChanged: (val) => selectedUnit = val ?? 'Years',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedFrequency,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                    ],
                    onChanged: (val) => selectedFrequency = val ?? 'Monthly',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => DropdownButtonFormField<int>(
                          value: selectedPurposeId,
                          decoration: InputDecoration(
                            labelText: 'Purpose (Optional)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: purposeCtrl.purposes.map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          )).toList(),
                          onChanged: (val) => selectedPurposeId = val,
                        )),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: AppTheme.primaryNavy),
                        tooltip: 'Add new purpose',
                        onPressed: () => _showAddPurposeDialog(context, purposeCtrl),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            savingCatCtrl.addSavingCategory(
                              name: nameController.text,
                              goalAmount: double.parse(goalAmountController.text),
                              duration: int.parse(durationController.text),
                              unit: selectedUnit,
                              frequency: selectedFrequency,
                              purposeId: selectedPurposeId,
                            );
                          }
                        },
                        child: const Text('Create Goal'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddPurposeDialog(BuildContext context, PurposeController purposeCtrl) {
    final nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('New Purpose'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Purpose Name'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                purposeCtrl.addPurpose(name: nameController.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddFundsDialog(
    BuildContext context, 
    dynamic goal, 
    SavingController savingCtrl,
    SavingCategoryController savingCatCtrl,
  ) {
    final amountController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('Add Funds to ${goal.name}'),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount (\$)',
            prefixIcon: Icon(Icons.attach_money),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (amountController.text.isNotEmpty) {
                try {
                  final amount = double.parse(amountController.text);
                  await savingCtrl.addSaving(amount: amount, savingCategoryId: goal.id);
                  // Refresh the categories to get updated currentAmount
                  await savingCatCtrl.getSavingCategories();
                  Get.back();
                } catch (e) {
                  // error handled in controller
                }
              }
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }
}
