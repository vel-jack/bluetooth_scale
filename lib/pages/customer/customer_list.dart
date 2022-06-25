import 'package:bluetooth_scale/db/db_helper.dart';
import 'package:bluetooth_scale/pages/customer/edit_customer.dart';
import 'package:bluetooth_scale/pages/customer/customer_profile.dart';
import 'package:flutter/material.dart';
import 'package:search_page/search_page.dart';

import '../../model/customer.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({Key? key}) : super(key: key);

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  DBHelper? dbHelper;
  List<Customer> customers = [];
  @override
  void initState() {
    dbHelper ??= DBHelper();
    refreshList();
    super.initState();
  }

  Future<void> refreshList() async {
    List<Customer> tmp = await dbHelper!.getCustomers();
    setState(() {
      customers = tmp;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Customers'),
          actions: customers.isNotEmpty
              ? [
                  IconButton(
                      tooltip: 'Search Customer',
                      onPressed: () {
                        showSearch(
                            context: context,
                            delegate: SearchPage<Customer>(
                              barTheme: Theme.of(context).copyWith(
                                textTheme: Theme.of(context).textTheme.copyWith(
                                      headline6: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
                                inputDecorationTheme:
                                    const InputDecorationTheme(
                                  hintStyle: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 20,
                                  ),
                                  focusedErrorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  border: InputBorder.none,
                                ),
                              ),
                              builder: (customer) => ListTile(
                                leading: CircleAvatar(
                                    child: Text(
                                  customer.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )),
                                title: Text(
                                  customer.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                subtitle: Text(
                                    'phone: ${customer.phone}\naadhaar: ${customer.aadhaar}'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (builder) {
                                    return CustomerProfile(
                                      customer: customer,
                                    );
                                  })).then((value) => refreshList());
                                },
                              ),
                              suggestion: const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'Search your customers using NAME, AADHAAR, PHONE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              failure: const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'No matching customer found, Please try different',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              filter: (customer) => [
                                customer.name,
                                customer.aadhaar,
                                customer.phone
                              ],
                              items: customers,
                              searchLabel: 'Search Customer',
                            ));
                      },
                      icon: const Icon(Icons.search_rounded))
                ]
              : null),
      body: RefreshIndicator(
        onRefresh: refreshList,
        child: ListView(
          children: [
            if (customers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 300),
                child: Text(
                  'Tap the +👤 button below to add new customer 👇️',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ListView.builder(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: customers.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade100,
                      child: Text(
                        customers[index].name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                  title: Text(
                    customers[index].name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text('id : ${customers[index].uid}'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) {
                      return CustomerProfile(
                        customer: customers[index],
                      );
                    })).then((value) => refreshList());
                  },
                );
              },
            ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (builder) {
            return const EditCustomer();
          })).then((value) => refreshList());
        },
        label: const Text('Add Customers'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }
}
