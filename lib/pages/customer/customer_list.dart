import 'package:bluetooth_scale/controller/search_controller.dart';
import 'package:bluetooth_scale/pages/customer/edit_customer.dart';
import 'package:bluetooth_scale/pages/customer/customer_profile.dart';
import 'package:bluetooth_scale/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerList extends StatelessWidget {
  const CustomerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers'), actions: [
        IconButton(
            tooltip: 'Search Customer',
            onPressed: () {
              if (customerController.customers.isEmpty) {
                return;
              }
              showSearch(
                      context: context,
                      delegate: search(context, customerController.customers))
                  .then((value) {
                debugPrint('$value');
              });
            },
            icon: const Icon(Icons.search_rounded))
      ]),
      body: Obx(() {
        return ListView(
          children: [
            if (customerController.customers.isEmpty)
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
              itemCount: customerController.customers.length,
              itemBuilder: (BuildContext context, int index) {
                final customer = customerController.customers[index];
                return ListTile(
                  leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade100,
                      child: Text(
                        customer.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                  title: Text(
                    customer.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text('id : ${customer.uid}'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) {
                      return CustomerProfile(
                        customer: customer,
                      );
                    }));
                  },
                );
              },
            ),
            const SizedBox(
              height: 100,
            )
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (builder) {
            return const EditCustomer();
          }));
        },
        label: const Text('Add Customers'),
        icon: const Icon(Icons.person_add),
      ),
    );
  }
}
