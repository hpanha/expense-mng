import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';

class ReportController extends GetxController {
  final ApiService api = ApiService();

  Rx<Map<String, dynamic>?> dailyReport = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> weeklyReport = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> monthlyReport = Rx<Map<String, dynamic>?>(null);

  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  Future<void> getDailyReport() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      var response = await api.get("reports/daily");
      dailyReport.value = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load daily report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getWeeklyReport() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      var response = await api.get("reports/weekly");
      weeklyReport.value = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load weekly report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMonthlyReport() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";
      var response = await api.get("reports/monthly");
      monthlyReport.value = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load monthly report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getDailyReport();
    getWeeklyReport();
    getMonthlyReport();
  }
}
