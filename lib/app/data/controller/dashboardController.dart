import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';

class DashboardController extends GetxController {
  final ApiService api = ApiService();

  var income = 0.0.obs;
  var expense = 0.0.obs;
  var balance = 0.0.obs;

  @override
  void onInit() {
    loadReport();
    super.onInit();
  }

  Future<void> loadReport() async {
    try {
      var data = await api.get("reports/monthly");

      income.value = double.parse(data['total_income'].toString());

      expense.value = double.parse(data['total_expense'].toString());

      balance.value = double.parse(data['balance'].toString());
    } catch (e) {
      // Set default values if API fails
      income.value = 0.0;
      expense.value = 0.0;
      balance.value = 0.0;

      Get.snackbar(
        'Error',
        'Failed to load reports. Please check your internet connection.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
