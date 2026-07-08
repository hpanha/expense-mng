import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';
import 'package:extend_system/app/data/models/saving.dart';

class SavingController extends GetxController {
  final ApiService api = ApiService();

  RxList<Saving> savings = <Saving>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  /// Total amount saved across all saving records
  double get totalSaved =>
      savings.fold(0.0, (sum, s) => sum + s.amount);

  @override
  void onInit() {
    super.onInit();
    getSavings();
  }

  Future<void> getSavings() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final response = await api.get("savings");
      if (response is List) {
        savings.value =
            response.map((x) => Saving.fromJson(x as Map<String, dynamic>)).toList();
      } else {
        savings.value = [];
      }
    } catch (e) {
      errorMessage.value = e.toString();
      savings.value = [];
      
      // Temporarily suppress the snackbar for 500 errors since the backend API 
      // is currently known to be broken (returns 500 on savings due to date format issue).
      if (!e.toString().contains('500')) {
        Get.snackbar(
          'Error',
          'Failed to load savings: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        print('Backend savings API is currently returning 500. Ignoring error.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSaving({
    required double amount,
    required int savingCategoryId,
  }) async {
    try {
      isLoading.value = true;
      await api.post("savings", {
        "amount": amount.toStringAsFixed(2),
        "saving_category_id": savingCategoryId,
      });
      await getSavings();
      Get.back();
      Get.snackbar(
        'Success',
        'Saving added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add saving: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSaving({
    required int id,
    required double amount,
    required int savingCategoryId,
  }) async {
    try {
      isLoading.value = true;
      await api.put("savings/$id", {
        "amount": amount.toStringAsFixed(2),
        "saving_category_id": savingCategoryId,
      });
      await getSavings();
      Get.back();
      Get.snackbar(
        'Success',
        'Saving updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update saving: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSaving(int id) async {
    try {
      await api.delete("savings/$id");
      await getSavings();
      Get.snackbar(
        'Success',
        'Saving deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete saving: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Returns all savings for a specific saving category
  List<Saving> getSavingsForCategory(int savingCategoryId) {
    return savings.where((s) => s.savingCategoryId == savingCategoryId).toList();
  }

  /// Returns the total deposited for a specific saving category
  double getTotalForCategory(int savingCategoryId) {
    return getSavingsForCategory(savingCategoryId)
        .fold(0.0, (sum, s) => sum + s.amount);
  }
}
