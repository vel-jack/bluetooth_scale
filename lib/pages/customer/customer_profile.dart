import 'dart:io';

import 'package:bluetooth_scale/model/customer.dart';
import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:bluetooth_scale/utils/constants.dart';
import 'package:bluetooth_scale/utils/pdf_api.dart';
import 'package:bluetooth_scale/utils/pdf_invoice_api.dart';
import 'package:bluetooth_scale/widgets/customer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_customer.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({Key? key, required this.customer}) : super(key: key);
  final Customer customer;
  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  late Rx<Customer> customer = Rx<Customer>(widget.customer);
  List<int> selectedIndex = [];

  @override
  void initState() {
    transactionController.loadCustomerTransactions(widget.customer.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final transactions = selectedIndex
              .map((e) => transactionController.customerTransactions[e])
              .toList();
          setState(() => selectedIndex.clear());
          try {
            var dir = Directory(filePath);
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
            // print(
            //     '$_filePath/${customer.name}_${formatter.format(DateTime.now())}.pdf');
            final pdf = await PdfInvoiceApi.generate(
              loc:
                  '$filePath/${customer.value.name}_${customer.value.phone}.pdf',
              customer: customer.value,
              transactions: transactions.isEmpty
                  ? transactionController.customerTransactions
                  : transactions,
            );
            PdfApi.openFile(pdf);
            Get.snackbar('Saved', 'Saved documents to downloads',
                leftBarIndicatorColor: Colors.green);
          } catch (_) {
            // debugPrint('Something happened...\n$e');
          }
        },
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedIndex.isNotEmpty) Text('${selectedIndex.length}x'),
            const Icon(Icons.description),
          ],
        ),
        label: const Text('Download Receipt'),
      ),
      appBar: AppBar(
        actions: [
          selectedIndex.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (builder) => AlertDialog(
                              title: const Text('Please confirm'),
                              content: Text(
                                  'Want to delete ${selectedIndex.length} item(s)?\n(Cannot recover after deletion)'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () {
                                      final transactions = selectedIndex
                                          .map((e) => transactionController
                                              .customerTransactions[e])
                                          .toList();
                                      transactionController.deleteTransactions(
                                          transactions, customer.value.uid);
                                      selectedIndex.clear();
                                      setState(() {});
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ))
                              ],
                            ));
                  },
                  icon: const Icon(Icons.delete_sweep))
              : PopupMenuButton(onSelected: (value) {
                  if (value == 0) {
                    showDialog(
                        context: context,
                        builder: (builder) => AlertDialog(
                              title: const Text('Delete Customer'),
                              content: Text(
                                  'Also ${customer.value.name}\'s purchase history will be deleted'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await customerController
                                          .deleteCustomer(customer.value.uid);
                                      Navigator.pop(context);

                                      Get.snackbar('Deleted',
                                          'Customer profile and purchased history deleted',
                                          leftBarIndicatorColor: Colors.yellow);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ))
                              ],
                            ));
                  }
                }, itemBuilder: (context) {
                  return const [
                    PopupMenuItem(
                      child: Text('Delete Customer'),
                      value: 0,
                    )
                  ];
                }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              return CustomerWidget(
                  customer: customer.value,
                  onEdit: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) {
                      return EditCustomer(
                        customer: customer.value,
                      );
                    })).then((value) {
                      if (value != null) {
                        customer.value = value;
                      }
                    });
                  });
            }),
            const Padding(
              padding: EdgeInsets.all(6.0),
              child: Text('Purchased History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Obx(() {
              return Flexible(
                child: transactionController.customerTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'History is empty',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '( ་ ⍸ ་ )',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemCount:
                            transactionController.customerTransactions.length,
                        itemBuilder: (BuildContext context, int index) {
                          TransactionX transaction =
                              transactionController.customerTransactions[index];
                          return ListTile(
                            title: Text(
                              transaction.date,
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Text('${transaction.weight} g'),
                            onTap: () {
                              if (selectedIndex.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  backgroundColor: Colors.blue,
                                  content:
                                      Text('Hold/long press to select item'),
                                  duration: Duration(seconds: 1),
                                ));
                              } else {
                                if (selectedIndex.contains(index)) {
                                  selectedIndex.remove(index);
                                } else {
                                  selectedIndex.add(index);
                                }
                                setState(() {});
                              }
                            },
                            tileColor: selectedIndex.contains(index)
                                ? Colors.blue.shade100
                                : null,
                            onLongPress: () {
                              if (selectedIndex.contains(index)) {
                                selectedIndex.remove(index);
                              } else {
                                selectedIndex.add(index);
                              }
                              setState(() {});
                            },
                          );
                        },
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
