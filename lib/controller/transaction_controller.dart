import 'package:bluetooth_scale/db/db_helper.dart';
import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:get/get.dart';

class TransactionController extends GetxController {
  static TransactionController instance = Get.find();
  Rx<List<TransactionX>> allTransactions = Rx<List<TransactionX>>([]);
  Rx<List<TransactionX>> customerTransactions = Rx<List<TransactionX>>([]);
  DBHelper? _dbHelper;
  @override
  void onInit() {
    _dbHelper ??= DBHelper();
    loadAllTransactions();
    super.onInit();
  }

  Future<void> loadAllTransactions() async {
    allTransactions.value = await _dbHelper!.getAllTx();
  }

  Future<void> loadCustomerTransactions(String uid) async {
    customerTransactions.value = [];
    customerTransactions.value = allTransactions.value
        .where((transaction) => transaction.customerID == uid)
        .toList();
  }

  Future<void> deleteTransaction(int transactionId, String uid) async {
    await _dbHelper!.deleteTransaction(transactionId);
    await loadAllTransactions();
    await loadCustomerTransactions(uid);
  }

  Future<void> addTransaction(TransactionX transaction) async {
    await _dbHelper!.addTransaction(transaction);
    loadAllTransactions();
  }
}
