import 'package:bluetooth_scale/db/db_helper.dart';
import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:get/get.dart';

class TransactionController extends GetxController {
  static TransactionController instance = Get.find();
  final Rx<List<TransactionX>> _allTransactions = Rx<List<TransactionX>>([]);
  final Rx<List<TransactionX>> _customerTransactions =
      Rx<List<TransactionX>>([]);
  List<TransactionX> get allTransactions => _allTransactions.value;
  List<TransactionX> get customerTransactions => _customerTransactions.value;
  DBHelper? _dbHelper;
  @override
  void onInit() {
    _dbHelper ??= DBHelper();
    loadAllTransactions();
    super.onInit();
  }

  Future<void> loadAllTransactions() async {
    _allTransactions.value = await _dbHelper!.getAllTx();
  }

  Future<void> loadCustomerTransactions(String uid) async {
    _customerTransactions.value = [];
    _customerTransactions.value = _allTransactions.value
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
