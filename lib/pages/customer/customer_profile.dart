import 'dart:io';

import 'package:bluetooth_scale/db/db_helper.dart';
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
  DBHelper? dbHelper;
  List<TransactionX> txlist = [];

  final _filePath = '/storage/emulated/0/Download/BScale';

  @override
  void initState() {
    dbHelper ??= DBHelper();
    refreshList();
    super.initState();
  }

  Future<void> refreshList() async {
    List<TransactionX> temp = await dbHelper!.getCustomerTx(customer.value.uid);
    setState(() {
      txlist = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: txlist.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                await refreshList();
                if (txlist.isNotEmpty) {
                  try {
                    var dir = Directory(_filePath);
                    if (!await dir.exists()) {
                      await dir.create(recursive: true);
                    }
                    // print(
                    //     '$_filePath/${customer.name}_${formatter.format(DateTime.now())}.pdf');
                    final pdf = await PdfInvoiceApi.generate(
                        loc:
                            '$_filePath/${customer.value.name}_${customer.value.phone}.pdf',
                        customer: customer.value,
                        transactions: txlist);
                    PdfApi.openFile(pdf);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to downloads')));
                  } catch (e) {
                    debugPrint('Something happened...\n$e');
                  }
                }
              },
              icon: const Icon(Icons.description),
              label: const Text('Download Receipt'),
            )
          : null,
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
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Deleted'),
                                  duration: Duration(milliseconds: 500),
                                ));
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
            Flexible(
              child: txlist.isEmpty
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
                      itemCount: txlist.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          tileColor:
                              index % 2 == 0 ? Colors.grey.shade100 : null,
                          // title: Text(txlist[index].customerName),
                          title: Text(
                            txlist[index].date,
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Text('${txlist[index].weight} g'),
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
                                              dbHelper!.deleteTransaction(
                                                  txlist[index].tid!);
                                              refreshList();
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Delete',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ))
                                      ],
                                    ));
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
