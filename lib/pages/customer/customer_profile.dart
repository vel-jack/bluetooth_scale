import 'dart:io';

import 'package:bluetooth_scale/db/db_helper.dart';
import 'package:bluetooth_scale/utils/blue_singleton.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/customer.dart';
import '../../model/transactionx.dart';
import '../../utils/pdf_api.dart';
import '../../utils/pdf_invoice_api.dart';
import 'edit_customer.dart';

class CustomerProfile extends StatefulWidget {
  const CustomerProfile({Key? key, required this.customer}) : super(key: key);
  final Customer customer;
  @override
  State<CustomerProfile> createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  late Customer customer;
  DBHelper? dbHelper;
  List<TransactionX> txlist = [];

  final _filePath = '/storage/emulated/0/Download/BScale';

  @override
  void initState() {
    customer = widget.customer;
    dbHelper ??= DBHelper();
    refreshList();
    super.initState();
  }

  Future<void> refreshList() async {
    List<TransactionX> temp = await dbHelper!.getCustomerTx(customer.uid);
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
                if (Singleton().name == '' ||
                    Singleton().email == '' ||
                    Singleton().phone == '') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Update Seller profile first'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

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
                            '$_filePath/${customer.name}_${customer.phone}.pdf',
                        customer: customer,
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
                            'Also ${customer.name}\'s purchase history will be deleted'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await dbHelper!
                                    .deleteCustomer(customer.uid)
                                    .then((value) => Navigator.pop(context));
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
            customerDetail(context),
            const Padding(
              padding: EdgeInsets.all(6.0),
              child: Text('Purchased History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Flexible(
              child: RefreshIndicator(
                onRefresh: () => refreshList(),
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
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ))
                                        ],
                                      ));
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customerDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              radius: 60,
              child: Text(
                customer.name.substring(0, 1).toUpperCase(),
                style:
                    const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  customer.name.length > 13
                      ? customer.name.substring(0, 13) + '...'
                      : customer.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'ID : ${customer.uid}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              ButtonBar(
                children: [
                  ElevatedButton.icon(
                      icon: const Icon(Icons.call),
                      onPressed: () =>
                          launchUrl(Uri.parse('tel:${customer.phone}')),
                      label: const Text('Call')),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (builder) {
                          return EditCustomer(
                            customer: customer,
                          );
                        })).then((value) {
                          if (value != null) {
                            setState(() {
                              customer = value;
                            });
                          }
                        });
                      },
                      label: const Text('Edit')),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
