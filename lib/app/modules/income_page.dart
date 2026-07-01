import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extend_system/app/data/controller/incomeController.dart';

class IncomePage extends StatelessWidget {
  IncomePage({super.key});

  final controller = Get.put(IncomeController());

  final Color navy = const Color(0xFF0A1F44);

  @override
  Widget build(BuildContext context) {
    controller.getIncome();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: navy,
        title: const Text("Income Records"),
        centerTitle: true,
      ),

      body: Obx(() {
        if (controller.incomes.isEmpty) {
          return const Center(
            child: Text("No income found"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.incomes.length,
          itemBuilder: (context, index) {
            final item = controller.incomes[index];

            return Dismissible(
              key: Key(item.id.toString()),

              direction: DismissDirection.endToStart,

              confirmDismiss: (direction) async {
                return await Get.dialog(
                  AlertDialog(
                    title: const Text("Delete Income?"),
                    content: const Text(
                        "Are you sure you want to delete this record?"),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text("Delete",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },

              onDismissed: (_) async {
                await controller.deleteIncome(item.id);

                Get.snackbar(
                  "Deleted",
                  "Income removed successfully",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: const Icon(Icons.delete, color: Colors.white),
                );
              },

              background: Container(
                padding: const EdgeInsets.only(right: 20),
                alignment: Alignment.centerRight,
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),

              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: navy,
                    child: const Icon(Icons.attach_money,
                        color: Colors.white),
                  ),

                  title: Text(
                    "\$${item.amount}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(item.description ?? ""),

                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}