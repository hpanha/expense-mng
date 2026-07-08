import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';
import 'package:extend_system/app/data/models/purpose.dart';

class PurposeController extends GetxController {
  final ApiService api = ApiService();

  RxList<Purpose> purposes = <Purpose>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();
    getPurposes();
  }

  Future<void> getPurposes() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      final response = await api.get("purposes");
      if (response is List) {
        purposes.value =
            response.map((x) => Purpose.fromJson(x as Map<String, dynamic>)).toList();
      } else {
        purposes.value = [];
      }
    } catch (e) {
      errorMessage.value = e.toString();
      purposes.value = [];
      Get.snackbar(
        'Error',
        'Failed to load purposes: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPurpose({required String name}) async {
    try {
      isLoading.value = true;
      await api.post("purposes", {"name": name});
      await getPurposes();
      Get.back();
      Get.snackbar(
        'Success',
        'Purpose added successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add purpose: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePurpose({required int id, required String name}) async {
    try {
      isLoading.value = true;
      await api.put("purposes/$id", {"name": name});
      await getPurposes();
      Get.back();
      Get.snackbar(
        'Success',
        'Purpose updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update purpose: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePurpose(int id) async {
    try {
      await api.delete("purposes/$id");
      await getPurposes();
      Get.snackbar(
        'Success',
        'Purpose deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete purpose: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
