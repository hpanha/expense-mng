
import 'package:get/get.dart';
import 'package:extend_system/app/data/services/api_service.dart';
import 'package:extend_system/app/data/models/transaction.dart';

class ExpenseController extends GetxController {
  final ApiService api = ApiService();

  RxList<Transaction> expenses =
      <Transaction>[].obs;

  Future<void> getExpense() async {
    var response =
        await api.get("expenses");

    expenses.value = List<Transaction>.from(
      response.map(
        (x) => Transaction.fromJson(x),
      ),
    );
  }
}