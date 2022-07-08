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
                transactions: transactionController.customerTransactions);
            PdfApi.openFile(pdf);

            Get.snackbar('Saved', 'Saved documents to downloads',
                leftBarIndicatorColor: Colors.green);
          } catch (_) {
            // debugPrint('Something happened...\n$e');
          }
        },
        icon: const Icon(Icons.description),
        label: const Text('Download Receipt'),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
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
            },
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Customer',
          )
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
                    : ListView.builder(
                        itemCount:
                            transactionController.customerTransactions.length,
                        itemBuilder: (BuildContext context, int index) {
                          TransactionX transaction =
                              transactionController.customerTransactions[index];
                          return ListTile(
                            tileColor:
                                index % 2 == 0 ? Colors.grey.shade100 : null,
                            // title: Text(txlist[index].customerName),
                            title: Text(
                              transaction.date,
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Text('${transaction.weight} g'),
                            onTap: () {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                backgroundColor: Colors.blue,
                                content: Text('Hold to delete'),
                                duration: Duration(seconds: 1),
                              ));
                            },
                            onLongPress: () {
                              showDialog(
                                  context: context,
                                  builder: (builder) => AlertDialog(
                                        title: const Text('Want to Delete?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel')),
                                          TextButton(
                                              onPressed: () {
                                                transactionController
                                                    .deleteTransaction(
                                                        transaction.tid!,
                                                        transaction.customerID);
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ))
                                        ],
                                      ));
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
