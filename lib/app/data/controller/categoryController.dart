import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';

class CategoryController extends GetxController {
  final ApiService api = ApiService();

  RxList categories = [].obs;
  RxList incomeCategories = [].obs;
  RxList expenseCategories = [].obs;
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
      final response = await api.get("categories");
      final list = response is List ? response : [];
      categories.value = list;

      // Split into typed lists (categories API only returns income & expense now)
      incomeCategories.value =
          list.where((c) => c['type'] == 'income').toList();
      expenseCategories.value =
          list.where((c) => c['type'] == 'expense').toList();
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

  /// Creates a category. Only [name] and [type] ("income" | "expense") are
  /// required. Saving goals are handled separately via SavingCategoryController.
  Future<void> addCategory({
    required String name,
    required String type,
  }) async {
    try {
      isLoading.value = true;
      await api.post("categories", {"name": name, "type": type});
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
  }) async {
    try {
      isLoading.value = true;
      await api.put("categories/$id", {"name": name, "type": type});
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
