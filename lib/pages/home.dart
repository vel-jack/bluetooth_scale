import 'dart:io';

import 'package:bluetooth_scale/pages/add_scale.dart';
import 'package:bluetooth_scale/pages/all_transactoins.dart';
import 'package:bluetooth_scale/pages/customer/customer_list.dart';
import 'package:bluetooth_scale/pages/device_list.dart';
import 'package:bluetooth_scale/db/db_helper.dart';
import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:bluetooth_scale/pages/owner/edit_profile.dart';
import 'package:bluetooth_scale/utils/constants.dart';
import 'package:bluetooth_scale/utils/pdf_api.dart';
import 'package:bluetooth_scale/utils/pdf_invoice_api.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'customer/customer_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TransactionX> transactions = [];
  DBHelper? dbHelper;
  String companyName = '';
  bool isMenuOpened = false;
  final DateFormat formatter = DateFormat('ddMMyyyyhhmmss');
  final _filePath = '/storage/emulated/0/Download/BScale';

  @override
  void initState() {
    dbHelper = DBHelper();
    refreshTx();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final navigationDrawer = ListView(
      children: [
        Obx(() {
          return UserAccountsDrawerHeader(
            accountName: Text(ownerController.owner.value.name),
            accountEmail: Text(ownerController.owner.value.email),
            currentAccountPicture: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: ownerController.profileImage.value == null
                  ? const AssetImage('assets/bioz.png')
                  : FileImage(ownerController.profileImage.value!)
                      as ImageProvider,
            ),
            otherAccountsPictures: [
              IconButton(
                  onPressed: () {
                    Get.to(() => const EditPofile());
                  },
                  color: Colors.white,
                  icon: const Icon(Icons.edit))
            ],
          );
        }),
        ListTile(
          title: const Text('Customers'),
          leading: const Icon(Icons.people),
          onTap: () {
            Get.to(() => const CustomerList());
          },
        ),
        ListTile(
          onTap: () async {
            if (await Permission.storage.request().isGranted) {
              try {
                var dir = Directory(_filePath);
                if (!await dir.exists()) {
                  await dir.create(recursive: true);
                }
                final pdf = await PdfInvoiceApi.generateCompleteData(
                    '$_filePath/CompleteDetails_${formatter.format(DateTime.now())}.pdf');
                await PdfApi.openFile(pdf);

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exported to Downloads')));
                // await pdf.copy(
                //     '/storage/emulated/0/Download/CompleteDetail${formatter.format(DateTime.now())}.pdf');
              } catch (e) {
                debugPrint('Something happened...\n$e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Failed to export'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            }
          },
          title: const Text('Export to PDF'),
          leading: const Icon(Icons.picture_as_pdf),
        ),
        ListTile(
          onTap: () {},
          title: const Text('Check for updates'),
          leading: const Icon(Icons.update),
        ),
        ListTile(
          onTap: () async {
            if (!await launchUrl(Uri.parse("https://www.bioz.in"))) {
              throw 'Can\'t open url';
            }
          },
          title: const Text('Visit our website'),
          leading: const Icon(Icons.language),
        ),
        ListTile(
          title: const Text('Contact Us'),
          leading: const Icon(Icons.message),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  tooltip: 'Call',
                  onPressed: () async {
                    if (!await launchUrl(Uri.parse('tel:9345967705'))) {
                      throw 'Can\'t open url';
                    }
                  },
                  color: Colors.blue,
                  icon: const Icon(Icons.call)),
              IconButton(
                  tooltip: 'Mail',
                  onPressed: () async {
                    if (!await launchUrl(Uri.parse('mailto:bioz@outlook.in'))) {
                      throw 'Can\'t open url';
                    }
                  },
                  color: Colors.blue,
                  icon: const Icon(
                    Icons.email,
                  ))
            ],
          ),
        ),
      ],
    );
    return WillPopScope(
      onWillPop: () async {
        if (isMenuOpened) {
          return false;
        }
        showDialog(
            context: context,
            builder: (builder) {
              return AlertDialog(
                title: const Text('Want to exit?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('No')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        MoveToBackground.moveTaskToBack();
                      },
                      child: const Text('Exit'))
                ],
              );
            });
        return false;
      },
      child: Scaffold(
        drawer: Drawer(
          child: navigationDrawer,
        ),
        appBar: AppBar(
          title: const Text('BScale'),
          actions: [
            Obx(() {
              return IconButton(
                  onPressed: () {
                    Get.to(() => const DeviceList());
                  },
                  icon: bluetoothController.isConnected
                      ? const Icon(
                          Icons.bluetooth_connected,
                          color: Colors.blue,
                        )
                      : const Icon(
                          Icons.bluetooth,
                          color: Colors.red,
                        ));
            }),
          ],
        ),
        body: ListView(
          children: [
            transactions.isEmpty
                ? const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 100),
                    child: Text(
                      'Tap the + button below to add new weight 👇️',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Recent sale',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            tileColor:
                                index % 2 == 0 ? Colors.grey.shade100 : null,
                            title: Text(
                              transactions[index].customerName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            leading: CircleAvatar(
                                backgroundColor: index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.shade100,
                                child: Text(
                                  transactions[index]
                                      .customerName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                            subtitle: Text.rich(TextSpan(children: [
                              const TextSpan(
                                  text: 'Date : ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text:
                                      transactions[index].date.substring(0, 10))
                            ])),
                            // Text(data[index].date.substring(0, 10)),
                            trailing: Text('${transactions[index].weight} g'),
                            onTap: () async {
                              await dbHelper
                                  ?.getCustomerByID(
                                      transactions[index].customerID)
                                  .then((customerx) {
                                if (customerx != null) {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (builder) {
                                    return CustomerProfile(customer: customerx);
                                  })).then((value) {
                                    refreshTx();
                                  });
                                }
                              });
                            },
                          );
                        },
                      ),
                      if (transactions.length == 10)
                        ListTile(
                            onTap: () async {
                              List<TransactionX> allTransactions =
                                  await dbHelper!.getAllTx();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (builder) {
                                return AllTransactions(
                                    transactions: allTransactions);
                              })).then((value) {
                                refreshTx();
                              });
                            },
                            subtitle: const Text(
                              'View more',
                              textAlign: TextAlign.center,
                            ),
                            title: const Icon(Icons.arrow_downward))
                    ],
                  ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
        floatingActionButton: Obx(() {
          if (bluetoothController.isConnected) {
            return FloatingActionButton.extended(
              label: const Text('Add Weight'),
              onPressed: () async {
                if (!await Permission.location.isPermanentlyDenied) {
                  Get.to(() => const AddScale());
                } else {
                  openAppSettings();
                }
              },
              backgroundColor: isMenuOpened ? Colors.blue.shade100 : null,
              icon: const Icon(Icons.add),
            );
          } else {
            return FloatingActionButton.extended(
              label: const Text('Connect Device'),
              onPressed: () {
                Get.to(() => const DeviceList());
              },
              icon: const Icon(Icons.bluetooth_searching),
              backgroundColor:
                  isMenuOpened ? Colors.blueGrey.shade100 : Colors.blueGrey,
            );
          }
        }),
      ),
    );
  }

  Future<void> refreshTx() async {
    List<TransactionX> tmp = await dbHelper!.getLastTen();
    setState(() {
      transactions = tmp;
    });
    debugPrint('REFRESHED');
  }
}
