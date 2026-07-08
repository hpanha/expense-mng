import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';
import 'package:extend_system/app/data/models/saving_category.dart';

class SavingCategoryController extends GetxController {
  final ApiService api = ApiService();

  RxList<SavingCategory> savingCategories = <SavingCategory>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    getSavingCategories();
  }

  Future<void> getSavingCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final response = await api.get("saving-categories");
      if (response is List) {
        savingCategories.value = response
            .map((x) => SavingCategory.fromJson(x as Map<String, dynamic>))
            .toList();
      } else {
        savingCategories.value = [];
      }
    } catch (e) {
      errorMessage.value = e.toString();
      // Temporarily suppress the snackbar for 500 errors since the backend API 
      // is currently known to be broken.
      if (!e.toString().contains('500')) {
        Get.snackbar(
          'Error',
          'Failed to load saving categories: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('Backend saving-categories API returned 500. Ignoring error to keep local state.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSavingCategory({
    required String name,
    required double goalAmount,
    double currentAmount = 0.0,
    required int duration,
    required String unit,
    required String frequency,
    int? purposeId,
  }) async {
    try {
      isLoading.value = true;
      final body = <String, dynamic>{
        "name": name,
        "goal_amount": goalAmount.toStringAsFixed(2),
        "current_amount": currentAmount.toStringAsFixed(2),
        "duration": duration,
        "unit": unit,
        "frequency": frequency,
        if (purposeId != null) "purpose_id": purposeId,
      };
      
      final response = await api.post("saving-categories", body);
      
      // Since the backend GET endpoint is returning 500, we add the new item locally
      if (response != null && response is Map<String, dynamic>) {
        savingCategories.add(SavingCategory.fromJson(response));
      }
      
      try {
        await getSavingCategories();
      } catch (e) {
        print('Ignored getSavingCategories error after add');
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Saving goal added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add saving goal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSavingCategory({
    required int id,
    required String name,
    required double goalAmount,
    double? currentAmount,
    required int duration,
    required String unit,
    required String frequency,
    int? purposeId,
  }) async {
    try {
      isLoading.value = true;
      final body = <String, dynamic>{
        "name": name,
        "goal_amount": goalAmount.toStringAsFixed(2),
        if (currentAmount != null)
          "current_amount": currentAmount.toStringAsFixed(2),
        "duration": duration,
        "unit": unit,
        "frequency": frequency,
        if (purposeId != null) "purpose_id": purposeId,
      };
      await api.put("saving-categories/$id", body);
      await getSavingCategories();
      Get.back();
      Get.snackbar(
        'Success',
        'Saving goal updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update saving goal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSavingCategory(int id) async {
    try {
      await api.delete("saving-categories/$id");
      await getSavingCategories();
      Get.snackbar(
        'Success',
        'Saving goal deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete saving goal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
