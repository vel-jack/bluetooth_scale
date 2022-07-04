import 'package:bluetooth_scale/db/db_helper.dart';
import 'package:bluetooth_scale/model/customer.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController {
  final Rx<List<Customer>> _customers = Rx<List<Customer>>([]);
  List<Customer> get customerr => _customers.value;
  DBHelper? _dbHelper;

  @override
  void onInit() {
    _dbHelper ??= DBHelper();
    loadCustomers();
    super.onInit();
  }

  Future<void> loadCustomers() async {
    _customers.value = await _dbHelper!.getCustomers();
  }

  void addCutomer(Customer customer) async {
    await _dbHelper!.addCustomer(customer);
    await loadCustomers();
  }

  void updateCustomer(Customer customer) async {
    await _dbHelper!.updateCustomer(customer);
    await loadCustomers();
  }

  void deleteCustomer(String uid) async {
    await _dbHelper!.deleteCustomer(uid);
    await loadCustomers();
  }
}
