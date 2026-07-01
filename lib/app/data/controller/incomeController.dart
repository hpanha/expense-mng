import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';
import 'package:extend_system/app/data/models/transaction.dart';

class IncomeController extends GetxController {
  final ApiService api = ApiService();

  RxList<Transaction> incomes = <Transaction>[].obs;
  RxList categories = [].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  RxString selectedCategory = "".obs;

  @override
  void onInit() {
    super.onInit();
    getIncome();
    getCategories();
  }

  Future<void> getIncome() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      var response = await api.get("incomes");

      if (response is List) {
        incomes.value = response
            .map((x) => Transaction.fromJson(x as Map<String, dynamic>))
            .toList();
      } else if (response is Map && (response).isEmpty) {
        incomes.value = [];
      } else {
        incomes.value = [];
      }
    } catch (e) {
      errorMessage.value = e.toString();
      incomes.value = [];
      Get.snackbar(
        'Error',
        'Failed to load incomes: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCategories() async {
    try {
      var response = await api.get("categories?type=income");
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

  Future<void> addIncome({
    required String amount,
    required String description,
    required String categoryId,
  }) async {
    try {
      isLoading.value = true;
      await api.post("incomes", {
        "amount": amount,
        "description": description,
        "date": DateTime.now().toIso8601String().split('T')[0],
        "category_id": categoryId.isEmpty ? null : categoryId,
      });

      await getIncome();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add income: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      await api.delete("incomes/$id");
      await getIncome();
      Get.snackbar(
        'Success',
        'Income deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete income: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateIncome({
    required int id,
    required String amount,
    required String description,
    required String categoryId,
  }) async {
    try {
      isLoading.value = true;
      await api.put("incomes/$id", {
        "amount": amount,
        "description": description,
        "date": DateTime.now().toIso8601String().split('T')[0],
        "category_id": categoryId.isEmpty ? null : categoryId,
      });

      await getIncome();
      Get.back();
      Get.snackbar(
        'Success',
        'Income updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update income: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
