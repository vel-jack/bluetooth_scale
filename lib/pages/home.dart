import 'package:bluetooth_scale/pages/add_scale.dart';
import 'package:bluetooth_scale/pages/device_list.dart';
import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:bluetooth_scale/utils/constants.dart';
import 'package:bluetooth_scale/widgets/drawer_widget.dart';
import 'package:bluetooth_scale/widgets/transaction_tile.dart';
import 'package:get/get.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'customer/customer_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    const navigationDrawer = DrawerWidget();
    return WillPopScope(
      onWillPop: () async {
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
        drawer: const Drawer(
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
        body: Obx(() {
          return ListView(
            children: [
              transactionController.allTransactions.value.isEmpty
                  ? const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 100),
                      child: Text(
                        'Tap the + button below to add new weight 👇️',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                          itemCount: transactionController
                              .allTransactions.value.length,
                          itemBuilder: (BuildContext context, int index) {
                            TransactionX transaction = transactionController
                                .allTransactions.value[index];
                            return TransactionTile(
                                transaction: transaction,
                                index: index,
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (builder) {
                                    return CustomerProfile(
                                        customer:
                                            customerController.getCustomerById(
                                      transaction.customerID,
                                    ));
                                  }));
                                });
                          },
                        ),
                      ],
                    ),
              const SizedBox(
                height: 100,
              )
            ],
          );
        }),
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
              icon: const Icon(Icons.add),
            );
          } else {
            return FloatingActionButton.extended(
              label: const Text('Connect Device'),
              onPressed: () {
                Get.to(() => const DeviceList());
              },
              icon: const Icon(Icons.bluetooth_searching),
              backgroundColor: Colors.blueGrey,
            );
          }
        }),
      ),
    );
  }
}
