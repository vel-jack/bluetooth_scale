import 'dart:io';

import 'package:bluetooth_scale/pages/all_transactoins.dart';
import 'package:bluetooth_scale/utils/blue_singleton.dart';
import 'package:bluetooth_scale/db/db_helper.dart';
import 'package:bluetooth_scale/logic/ble_status/ble_status_cubit.dart';
import 'package:bluetooth_scale/logic/connection/ble_cnx_cubit.dart';
import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:bluetooth_scale/pages/add_scale.dart';
import 'package:bluetooth_scale/pages/select_device.dart';
import 'package:bluetooth_scale/pages/user/edit_profile.dart';
import 'package:bluetooth_scale/utils/pdf_api.dart';
import 'package:bluetooth_scale/utils/pdf_invoice_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'customer/customer_list.dart';
import 'package:flutter/material.dart';
import 'package:backdrop/backdrop.dart';
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
    FlutterBluetoothSerial.instance.ensurePermissions();
    listenBluetoothState();
    setBusiness();
    refreshTx();
    super.initState();
  }

  void listenBluetoothState() {
    FlutterBluetoothSerial.instance.onStateChanged().listen((event) {
      if (mounted) {
        if (event == BluetoothState.STATE_OFF) {
          BlocProvider.of<BleStatusCubit>(context).emitOff();
        } else if (event == BluetoothState.STATE_ON) {
          BlocProvider.of<BleStatusCubit>(context).emitOn();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
      child: BackdropScaffold(
        backLayerBackgroundColor: Colors.white,
        stickyFrontLayer: true,
        frontLayerScrim: const Color.fromARGB(200, 245, 245, 245),
        frontLayerBackgroundColor: Colors.white,
        onBackLayerRevealed: () {
          setState(() {
            isMenuOpened = true;
          });
        },
        onBackLayerConcealed: () {
          setState(() {
            isMenuOpened = false;
          });
        },
        appBar: AppBar(
          title: const Text('BScale'),
          leading: const BackdropToggleButton(
            icon: AnimatedIcons.close_menu,
            color: Colors.black,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const CustomerList()))
                    .then((value) => refreshTx());
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isMenuOpened ? 'Customers' : '',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const Icon(
                    Icons.people,
                    color: Colors.black45,
                    size: 26,
                  ),
                ],
              ),
            ),
          ],
        ),
        backLayer: backLayerTiles(),
        frontLayer: RefreshIndicator(
          onRefresh: () => refreshTx(),
          child: ListView(
            children: [
              Column(
                children: [
                  Tooltip(
                    triggerMode: TooltipTriggerMode.tap,
                    message: 'Press  ☰ Menu  to update profile',
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade100,
                      radius: 70,
                      backgroundImage: Singleton().profileImage == null
                          ? const AssetImage('assets/bioz.png')
                          : FileImage(Singleton().profileImage!)
                              as ImageProvider,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      companyName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const Divider(
                indent: 100,
                endIndent: 100,
                thickness: 2,
              ),
              transactions.isEmpty
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
                          itemCount: transactions.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              tileColor:
                                  index % 2 == 0 ? Colors.grey.shade100 : null,
                              title: Text(
                                transactions[index].customerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                                    text: transactions[index]
                                        .date
                                        .substring(0, 10))
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
                                      return CustomerProfile(
                                          customer: customerx);
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
        ),
        floatingActionButton: BlocBuilder<ConnectionCubit, ConnectState>(
            builder: (context, state) {
          if (state is BleConnected) {
            return FloatingActionButton.extended(
              label: const Text('Add Weight'),
              onPressed: isMenuOpened
                  ? null
                  : () async {
                      if (!await Permission.location.isPermanentlyDenied) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (builder) {
                          return AddScale(connection: state.connection!);
                        })).then((value) => refreshTx());
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
              onPressed: isMenuOpened
                  ? null
                  : () {
                      BlocProvider.of<BleStatusCubit>(context).updateStatus();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (builder) {
                        return const SelectDevice();
                      })).then((value) => listenBluetoothState());
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

  void setBusiness() {
    setState(() {
      companyName = Singleton().business;
    });
  }

  Future<void> refreshTx() async {
    listenBluetoothState();
    List<TransactionX> tmp = await dbHelper!.getLastTen();
    setState(() {
      transactions = tmp;
    });
    debugPrint('REFRESHED');
  }

  ListView backLayerTiles() {
    return ListView(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        BlocBuilder<ConnectionCubit, ConnectState>(
          builder: (context, state) {
            if (state is BleConnected) {
              return ListTile(
                textColor: Colors.blue,
                title: const Text('Connected'),
                leading:
                    const Icon(Icons.bluetooth_connected, color: Colors.blue),
                trailing: TextButton.icon(
                  label: const Text(
                    'Disconnect',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    state.connection!.close();
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                ),
              );
            } else {
              return ListTile(
                textColor: Colors.blue,
                iconColor: Colors.blue,
                title: const Text('Tap to connect device'),
                leading: const Icon(Icons.bluetooth),
                onTap: () {
                  BlocProvider.of<BleStatusCubit>(context).updateStatus();
                  Navigator.push(context, MaterialPageRoute(builder: (builder) {
                    return const SelectDevice();
                  })).then((value) => listenBluetoothState());
                },
              );
            }
          },
        ),
        ListTile(
          onTap: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => const EditPofile()))
                .then((value) {
              setBusiness();
              listenBluetoothState();
            });
          },
          title: const Text('Update Profile'),
          leading: const Icon(Icons.person),
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
                  icon: const Icon(Icons.call)),
              IconButton(
                  tooltip: 'Mail',
                  onPressed: () async {
                    if (!await launchUrl(Uri.parse('mailto:bioz@outlook.in'))) {
                      throw 'Can\'t open url';
                    }
                  },
                  icon: const Icon(
                    Icons.email,
                  ))
            ],
          ),
        ),
      ],
    );
  }
}


// Todo - Add Connect/Disconnect Button in backdrop_layer