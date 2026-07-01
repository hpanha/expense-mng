import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';
import 'package:extend_system/app/data/models/transaction.dart';

class ExpenseController extends GetxController {
  final ApiService api = ApiService();

  RxList<Transaction> expenses = <Transaction>[].obs;
  RxList categories = [].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  RxString selectedCategory = "".obs;

  @override
  void onInit() {
    super.onInit();
    getExpenses();
    getCategories();
  }

  Future<void> getExpenses() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      var response = await api.get("expenses");

      if (response is List) {
        expenses.value = response
            .map((x) => Transaction.fromJson(x as Map<String, dynamic>))
            .toList();
      } else if (response is Map && (response).isEmpty) {
        expenses.value = [];
      } else {
        expenses.value = [];
      }
    } catch (e) {
      errorMessage.value = e.toString();
      expenses.value = [];
      Get.snackbar(
        'Error',
        'Failed to load expenses: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCategories() async {
    try {
      var response = await api.get("categories?type=expense");
      categories.value = response is List ? response : [];
    } catch (e) {
      categories.value = [];
      Get.snackbar(
        'Error',
        'Failed to load categories: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> addExpense({
    required String amount,
    required String description,
    required String categoryId,
  }) async {
    try {
      isLoading.value = true;
      await api.post("expenses", {
        "amount": amount,
        "description": description,
        "date": DateTime.now().toIso8601String().split('T')[0],
        "category_id": categoryId.isEmpty ? null : categoryId,
      });

      await getExpenses();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add expense: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await api.delete("expenses/$id");
      await getExpenses();
      Get.snackbar(
        'Success',
        'Expense deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete expense: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateExpense({
    required int id,
    required String amount,
    required String description,
    required String categoryId,
  }) async {
    try {
      isLoading.value = true;
      await api.put("expenses/$id", {
        "amount": amount,
        "description": description,
        "date": DateTime.now().toIso8601String().split('T')[0],
        "category_id": categoryId.isEmpty ? null : categoryId,
      });

      await getExpenses();
      Get.back();
      Get.snackbar(
        'Success',
        'Expense updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update expense: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
