import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/expenseController.dart';
import 'package:extend_system/app/theme/app_theme.dart';

class ExpensesPage extends StatelessWidget {
  final bool showFab;
  ExpensesPage({super.key, this.showFab = true});

  final controller = Get.put(ExpenseController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppTheme.backgroundTeal,
      body: Obx(() {
        if (controller.isLoading.value && controller.expenses.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            ),
          );
        }

        final totalExpense = controller.expenses.fold<double>(0, (sum, item) => sum + item.amount);

        return RefreshIndicator(
          onRefresh: () => controller.getExpenses(),
          color: AppTheme.primaryTeal,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total Expense Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC84B31), Color(0xFF942F1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF942F1C).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Total Expense",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "\$${totalExpense.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Transactions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.darkTeal,
                ),
              ),
              const SizedBox(height: 10),

              if (controller.expenses.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.money_off, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          "No expenses registered yet",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...controller.expenses.map((expense) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2222) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: Colors.red[50],
                        child: const Icon(Icons.arrow_upward_rounded, color: Colors.red, size: 20),
                      ),
                      title: Text(
                        expense.description,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkTeal,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        expense.category?.name ?? 'Shopping',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.darkTeal.withOpacity(0.6),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "-\$${expense.amount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                expense.date,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded, color: Colors.grey[600], size: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (value) {
                              if (value == 'details') {
                                _showDetailsDialog(context, expense);
                              } else if (value == 'delete') {
                                _showDeleteDialog(context, expense.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'details',
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, color: Colors.blue, size: 18),
                                    SizedBox(width: 8),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      }),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.bottomSheet(
                  const AddExpenseForm(),
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryTeal,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            )
          : null,
    );
  }

  void _showDetailsDialog(BuildContext context, dynamic expense) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.primaryTeal),
            const SizedBox(width: 10),
            Text('Transaction Details', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkTeal)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Description', expense.description),
            const Divider(),
            _buildDetailRow('Category', expense.category?.name ?? 'Shopping'),
            const Divider(),
            _buildDetailRow('Amount', '-\$${expense.amount.toStringAsFixed(2)}', valueColor: Colors.red),
            const Divider(),
            _buildDetailRow('Date', expense.date),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Expense', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkTeal)),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteExpense(id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppTheme.darkTeal,
            ),
          ),
        ],
      ),
    );
  }
}

class AddExpenseForm extends StatefulWidget {
  const AddExpenseForm({super.key});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final controller = Get.put(ExpenseController());
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descController = TextEditingController();
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Refresh categories when the form opens so newly added categories show up
    controller.getCategories();
  }

  @override
  void dispose() {
    amountController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      if (selectedCategoryId == null || selectedCategoryId!.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select a category',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[300],
        );
        return;
      }

      controller.addExpense(
        amount: amountController.text,
        description: descController.text,
        categoryId: selectedCategoryId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Add Expense",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixIconColor: AppTheme.primaryNavy,
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
                    return 'Amount is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'What is this expense for?',
                  prefixIcon: const Icon(Icons.description),
                  prefixIconColor: AppTheme.primaryNavy,
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
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: controller.categories.isEmpty
                        ? 'No categories available'
                        : 'Select a category',
                    prefixIcon: const Icon(Icons.category),
                    prefixIconColor: AppTheme.primaryNavy,
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
                  items: controller.categories.isEmpty
                      ? []
                      : controller.categories
                            .map((category) {
                              return DropdownMenuItem<String>(
                                value: category['id'].toString(),
                                child: Text(category['name'] ?? 'Unnamed'),
                              );
                            })
                            .toList()
                            .cast<DropdownMenuItem<String>>(),
                  onChanged: controller.categories.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            selectedCategoryId = value;
                          });
                        },
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: controller.isLoading.value
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
                        : const Icon(Icons.check),
                    label: Text(
                      controller.isLoading.value ? 'Saving...' : 'Save Expense',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
