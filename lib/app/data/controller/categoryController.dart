import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';

class CategoryController extends GetxController {
  final ApiService api = ApiService();

  RxList categories = [].obs;
  RxList incomeCategories = [].obs;
  RxList expenseCategories = [].obs;
  RxList savingCategories = [].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    getCategories();
  }

  Future<void> getCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      var response = await api.get("categories");
      categories.value = response;

      // Separate into income and expense categories
      incomeCategories.value = response
          .where((c) => c['type'] == 'income')
          .toList();
      expenseCategories.value = response
          .where((c) => c['type'] == 'expense')
          .toList();
      savingCategories.value = response
          .where((c) => c['type'] == 'saving')
          .toList();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load categories: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory({
    required String name,
    required String type,
    double? savingGoalAmount,
    double? savingCurrentAmount,
    String? savingTargetDate,
    String? savingFrequency,
    double? savingFrequencyAmount,
    double? savingCompletionPercentage,
    String? savingIcon,
  }) async {
    try {
      isLoading.value = true;
      final Map<String, dynamic> body = {
        "name": name,
        "type": type,
      };
      if (type == 'saving') {
        body['saving_goal_amount'] = savingGoalAmount;
        body['saving_current_amount'] = savingCurrentAmount;
        body['saving_target_date'] = savingTargetDate;
        body['saving_frequency'] = savingFrequency;
        body['saving_frequency_amount'] = savingFrequencyAmount;
        body['saving_completion_percentage'] = savingCompletionPercentage;
        body['saving_icon'] = savingIcon;
      }
      await api.post("categories", body);

      await getCategories();
      Get.back();
      Get.snackbar(
        'Success',
        'Category added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add category: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required String type,
    double? savingGoalAmount,
    double? savingCurrentAmount,
    String? savingTargetDate,
    String? savingFrequency,
    double? savingFrequencyAmount,
    double? savingCompletionPercentage,
    String? savingIcon,
  }) async {
    try {
      isLoading.value = true;
      final Map<String, dynamic> body = {
        "name": name,
        "type": type,
      };
      if (type == 'saving') {
        body['saving_goal_amount'] = savingGoalAmount;
        body['saving_current_amount'] = savingCurrentAmount;
        body['saving_target_date'] = savingTargetDate;
        body['saving_frequency'] = savingFrequency;
        body['saving_frequency_amount'] = savingFrequencyAmount;
        body['saving_completion_percentage'] = savingCompletionPercentage;
        body['saving_icon'] = savingIcon;
      }
      await api.put("categories/$id", body);

      await getCategories();
      Get.back();
      Get.snackbar(
        'Success',
        'Category updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update category: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await api.delete("categories/$id");
      await getCategories();
      Get.snackbar(
        'Success',
        'Category deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete category: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
