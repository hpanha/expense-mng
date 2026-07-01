import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/categoryController.dart';
import 'package:extend_system/app/theme/app_theme.dart';

class CategoryPage extends StatelessWidget {
  CategoryPage({super.key});

  final controller = Get.put(CategoryController());

  void _showCategoryDialog({Map<String, dynamic>? category}) {
    final nameController = TextEditingController(text: category?['name']);
    final formKey = GlobalKey<FormState>();
    String selectedType = category?['type'] ?? 'income';

    final goalAmountController = TextEditingController(
        text: category?['saving_goal_amount']?.toString() ?? '');
    final currentAmountController = TextEditingController(
        text: category?['saving_current_amount']?.toString() ?? '0');
    
    Map<String, dynamic> getDurationFromTargetDate(String? targetDateStr, String? createdAtStr) {
      if (targetDateStr == null || targetDateStr.isEmpty) {
        return {'value': 1, 'unit': 'years'};
      }
      final targetDate = DateTime.tryParse(targetDateStr);
      if (targetDate == null) {
        return {'value': 1, 'unit': 'years'};
      }
      final referenceDate = createdAtStr != null ? (DateTime.tryParse(createdAtStr) ?? DateTime.now()) : DateTime.now();
      final today = DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
      final difference = targetDate.difference(today);
      final days = difference.inDays;
      if (days <= 0) return {'value': 1, 'unit': 'days'};
      if (days % 365 == 0) return {'value': (days / 365).round(), 'unit': 'years'};
      if (days % 30 == 0) return {'value': (days / 30).round(), 'unit': 'months'};
      if (days % 7 == 0) return {'value': (days / 7).round(), 'unit': 'weeks'};
      return {'value': days, 'unit': 'days'};
    }

    final initialDuration = category?['saving_target_date'] != null
        ? getDurationFromTargetDate(category?['saving_target_date'], category?['created_at'])
        : {'value': 1, 'unit': 'years'};

    final durationController = TextEditingController(text: initialDuration['value'].toString());
    String selectedDurationUnit = initialDuration['unit'].toString();
    String selectedFrequency = category?['saving_frequency'] ?? 'monthly';
    String selectedIcon = category?['saving_icon'] ?? 'medical';

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              Widget buildPreviewCard() {
                final goal = double.tryParse(goalAmountController.text) ?? 0.0;
                final duration = int.tryParse(durationController.text) ?? 0;
                if (goal <= 0 || duration <= 0) return const SizedBox.shrink();
                
                final now = DateTime.now();
                DateTime targetDate;
                if (selectedDurationUnit == 'days') {
                  targetDate = now.add(Duration(days: duration));
                } else if (selectedDurationUnit == 'weeks') {
                  targetDate = now.add(Duration(days: duration * 7));
                } else if (selectedDurationUnit == 'months') {
                  targetDate = DateTime(now.year, now.month + duration, now.day);
                } else {
                  targetDate = DateTime(now.year + duration, now.month, now.day);
                }
                
                final today = DateTime(now.year, now.month, now.day);
                final difference = targetDate.difference(today);
                final totalDays = difference.inDays;
                
                double frequencyAmount = 0.0;
                if (totalDays > 0) {
                  if (selectedFrequency == 'daily') {
                    frequencyAmount = goal / totalDays;
                  } else if (selectedFrequency == 'weekly') {
                    frequencyAmount = goal / (totalDays / 7.0);
                  } else if (selectedFrequency == 'monthly') {
                    final totalMonths = (targetDate.year - today.year) * 12 + (targetDate.month - today.month);
                    final double monthsDouble = totalMonths > 0 ? totalMonths.toDouble() : (totalDays / 30.0);
                    frequencyAmount = goal / monthsDouble;
                  }
                } else {
                  frequencyAmount = goal;
                }
                
                final formattedDate = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
                final freqLabel = selectedFrequency == 'daily' ? 'day' : selectedFrequency == 'weekly' ? 'week' : 'month';
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calculate, color: Colors.blue[800], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Saving Target Estimate',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target Date: $formattedDate',
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                          children: [
                            const TextSpan(text: 'Estimated saving: '),
                            TextSpan(
                              text: '\$${frequencyAmount.toStringAsFixed(2)} / $freqLabel',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category == null ? 'Add Category' : 'Edit Category',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          hintText: 'e.g., Salary, Food, Transport',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryNavy,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Category name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryNavy,
                              width: 2,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'income',
                            child: Text('Income'),
                          ),
                          DropdownMenuItem(
                            value: 'expense',
                            child: Text('Expense'),
                          ),
                          DropdownMenuItem(
                            value: 'saving',
                            child: Text('Saving'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedType = value ?? 'income';
                          });
                        },
                      ),
                      if (selectedType == 'saving') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: goalAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Saving Goal Amount (\$)',
                            hintText: 'e.g., 5000',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (_) => setDialogState(() {}),
                          validator: (value) {
                            if (selectedType == 'saving') {
                              if (value == null || value.isEmpty) {
                                return 'Goal amount is required';
                              }
                              final val = double.tryParse(value);
                              if (val == null || val <= 0) {
                                return 'Please enter a valid positive number';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: currentAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Current Saved Amount (\$)',
                            hintText: 'e.g., 1200',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (_) => setDialogState(() {}),
                          validator: (value) {
                            if (selectedType == 'saving') {
                              if (value != null && value.isNotEmpty) {
                                final val = double.tryParse(value);
                                if (val == null || val < 0) {
                                  return 'Please enter a valid number';
                                }
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: durationController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Duration',
                                  hintText: 'e.g., 1',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (_) => setDialogState(() {}),
                                validator: (value) {
                                  if (selectedType == 'saving') {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    final val = int.tryParse(value);
                                    if (val == null || val <= 0) {
                                      return 'Must be > 0';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                value: selectedDurationUnit,
                                decoration: InputDecoration(
                                  labelText: 'Unit',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'days', child: Text('Days')),
                                  DropdownMenuItem(value: 'weeks', child: Text('Weeks')),
                                  DropdownMenuItem(value: 'months', child: Text('Months')),
                                  DropdownMenuItem(value: 'years', child: Text('Years')),
                                ],
                                onChanged: (value) {
                                  setDialogState(() {
                                    selectedDurationUnit = value ?? 'years';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedFrequency,
                          decoration: InputDecoration(
                            labelText: 'Saving Frequency',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'daily', child: Text('Daily')),
                            DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                            DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedFrequency = value ?? 'monthly';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedIcon,
                          decoration: InputDecoration(
                            labelText: 'Icon',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'medical', child: Text('🏥 Medical')),
                            DropdownMenuItem(value: 'car', child: Text('🚗 Car')),
                            DropdownMenuItem(value: 'house', child: Text('🏠 House')),
                            DropdownMenuItem(value: 'travel', child: Text('✈️ Travel')),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedIcon = value ?? 'medical';
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        buildPreviewCard(),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Obx(
                              () => ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryNavy,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          double? goalAmount;
                                          double? currentAmount;
                                          String? targetDateStr;
                                          double? frequencyAmount;
                                          double? completionPercentage;

                                          if (selectedType == 'saving') {
                                            goalAmount = double.parse(goalAmountController.text);
                                            currentAmount = double.tryParse(currentAmountController.text) ?? 0.0;
                                            final duration = int.parse(durationController.text);
                                            final now = DateTime.now();
                                            
                                            DateTime targetDate;
                                            if (selectedDurationUnit == 'days') {
                                              targetDate = now.add(Duration(days: duration));
                                            } else if (selectedDurationUnit == 'weeks') {
                                              targetDate = now.add(Duration(days: duration * 7));
                                            } else if (selectedDurationUnit == 'months') {
                                              targetDate = DateTime(now.year, now.month + duration, now.day);
                                            } else {
                                              targetDate = DateTime(now.year + duration, now.month, now.day);
                                            }
                                            
                                            targetDateStr = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
                                            
                                            final today = DateTime(now.year, now.month, now.day);
                                            final totalDays = targetDate.difference(today).inDays;
                                            
                                            double rawFrequencyAmount = 0.0;
                                            if (totalDays > 0) {
                                              if (selectedFrequency == 'daily') {
                                                rawFrequencyAmount = goalAmount / totalDays;
                                              } else if (selectedFrequency == 'weekly') {
                                                rawFrequencyAmount = goalAmount / (totalDays / 7.0);
                                              } else if (selectedFrequency == 'monthly') {
                                                final totalMonths = (targetDate.year - today.year) * 12 + (targetDate.month - today.month);
                                                final double monthsDouble = totalMonths > 0 ? totalMonths.toDouble() : (totalDays / 30.0);
                                                rawFrequencyAmount = goalAmount / monthsDouble;
                                              }
                                            } else {
                                              rawFrequencyAmount = goalAmount;
                                            }

                                            frequencyAmount = double.parse(rawFrequencyAmount.toStringAsFixed(2));
                                            completionPercentage = double.parse(((currentAmount / goalAmount) * 100).clamp(0.0, 100.0).toStringAsFixed(1));
                                          }

                                          if (category == null) {
                                            controller.addCategory(
                                              name: nameController.text,
                                              type: selectedType,
                                              savingGoalAmount: goalAmount,
                                              savingCurrentAmount: currentAmount,
                                              savingTargetDate: targetDateStr,
                                              savingFrequency: selectedType == 'saving' ? selectedFrequency : null,
                                              savingFrequencyAmount: frequencyAmount,
                                              savingCompletionPercentage: completionPercentage,
                                              savingIcon: selectedType == 'saving' ? selectedIcon : null,
                                            );
                                          } else {
                                            controller.updateCategory(
                                              id: category['id'],
                                              name: nameController.text,
                                              type: selectedType,
                                              savingGoalAmount: goalAmount,
                                              savingCurrentAmount: currentAmount,
                                              savingTargetDate: targetDateStr,
                                              savingFrequency: selectedType == 'saving' ? selectedFrequency : null,
                                              savingFrequencyAmount: frequencyAmount,
                                              savingCompletionPercentage: completionPercentage,
                                              savingIcon: selectedType == 'saving' ? selectedIcon : null,
                                            );
                                          }
                                        }
                                      },
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(category == null ? 'Add' : 'Update'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
            ),
          );
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No categories yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a category to get started',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.getCategories(),
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _buildCategorySection(
                'Income Categories',
                controller.incomeCategories,
              ),
              const SizedBox(height: 24),
              _buildCategorySection(
                'Expense Categories',
                controller.expenseCategories,
              ),
              const SizedBox(height: 24),
              _buildCategorySection(
                'Saving Categories',
                controller.savingCategories,
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: AppTheme.primaryNavy,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Widget _buildCategorySection(String title, RxList categoryList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
        ),
        Obx(
          () => categoryList.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No categories',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryList.length,
                  itemBuilder: (context, index) {
                    final category = categoryList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 0,
                      ),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: category['type'] == 'income'
                              ? Colors.green[100]
                              : (category['type'] == 'saving'
                                  ? Colors.blue[100]
                                  : Colors.red[100]),
                          child: Icon(
                            category['type'] == 'income'
                                ? Icons.add_circle
                                : (category['type'] == 'saving'
                                    ? _getSavingIcon(category['saving_icon'])
                                    : Icons.remove_circle),
                            color: category['type'] == 'income'
                                ? Colors.green
                                : (category['type'] == 'saving'
                                    ? Colors.blue
                                    : Colors.red),
                          ),
                        ),
                        title: Text(
                          category['name'] ?? 'Unnamed',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: category['type'] == 'saving'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Goal: \$${category['saving_goal_amount'] ?? '0'} (Saved: \$${category['saving_current_amount'] ?? '0'})',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${category['saving_completion_percentage']?.toStringAsFixed(0) ?? '0'}% completed • \$${category['saving_frequency_amount'] ?? '0'}/${category['saving_frequency'] ?? 'monthly'}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                category['type'] == 'income' ? 'Income' : 'Expense',
                                style: TextStyle(
                                  color: category['type'] == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: AppTheme.primaryNavy,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                              onTap: () =>
                                  _showCategoryDialog(category: category),
                            ),
                            PopupMenuItem(
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                              onTap: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('Delete Category'),
                                    content: Text(
                                      'Are you sure you want to delete "${category['name']}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          controller.deleteCategory(
                                            category['id'],
                                          );
                                          Get.back();
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _getSavingIcon(String? iconName) {
    switch (iconName) {
      case 'medical':
        return Icons.medical_services;
      case 'car':
        return Icons.directions_car;
      case 'house':
        return Icons.home;
      case 'travel':
        return Icons.flight_takeoff;
      default:
        return Icons.savings;
    }
  }
}
