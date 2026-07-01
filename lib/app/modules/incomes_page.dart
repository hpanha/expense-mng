import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/incomeController.dart';
import 'package:extend_system/app/modules/widget/message_popup.dart';
import 'package:extend_system/app/theme/app_theme.dart';

class IncomesPage extends StatelessWidget {
  final bool showFab;
  IncomesPage({super.key, this.showFab = true});

  final controller = Get.put(IncomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.incomes.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
            ),
          );
        }

        if (controller.incomes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_money_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No incomes yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first income to get started',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.getIncome(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.incomes.length,
            itemBuilder: (context, index) {
              final income = controller.incomes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: const Icon(Icons.add_circle, color: Colors.green),
                  ),
                  title: Text(
                    income.description,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    income.category?.name ?? 'Uncategorized',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+\$${income.amount}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        income.date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  onLongPress: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Delete Income'),
                        content: Text(
                          'Are you sure you want to delete this income?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              controller.deleteIncome(income.id);
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
              );
            },
          ),
        );
      }),
      floatingActionButton: showFab
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.bottomSheet(
                  const AddIncomeForm(),
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryNavy,
              icon: const Icon(Icons.add),
              label: const Text('Add Income'),
            )
          : null,
    );
  }
}

class AddIncomeForm extends StatefulWidget {
  const AddIncomeForm({super.key});

  @override
  State<AddIncomeForm> createState() => _AddIncomeFormState();
}

class _AddIncomeFormState extends State<AddIncomeForm> {
  final controller = Get.put(IncomeController());
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final descController = TextEditingController();
  String? selectedCategoryId;

  @override
  void dispose() {
    amountController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _submitForm() async {
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

      await controller.addIncome(
        amount: amountController.text,
        description: descController.text,
        categoryId: selectedCategoryId!,
      );

      Get.back();
      await controller.getIncome();
      await Future.delayed(const Duration(milliseconds: 200));
      await showSuccessPopup("Income Added Successfully!");
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
                "Add Income",
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
                  hintText: 'What is this income from?',
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
                      controller.isLoading.value ? 'Saving...' : 'Save Income',
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
