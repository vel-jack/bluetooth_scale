import 'dart:async';

import 'dart:typed_data';
import 'package:bluetooth_scale/db/db_helper.dart';
import 'package:bluetooth_scale/logic/connection/ble_cnx_cubit.dart';
import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:bluetooth_scale/pages/customer/edit_customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';
import 'package:search_page/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../model/customer.dart';
import '../utils/blue_singleton.dart';
import 'customer/customer_list.dart';

class AddScale extends StatefulWidget {
  const AddScale({Key? key, required this.connection}) : super(key: key);
  final BluetoothConnection connection;
  @override
  _AddScaleState createState() => _AddScaleState();
}

class _AddScaleState extends State<AddScale> {
  int totalGram = 0;
  bool isStarted = false;
  int cValue = 0;
  String cdate = '';
  DBHelper? dbHelper;
  bool isThousand = false;
  double limit = 600.0;
  double divider = 1000.0;

  StreamController<int> streamController = StreamController<int>();

  StreamSink<int> get streamSink => streamController.sink;
  Stream<int> get streamData => streamController.stream;
  List<Customer> customers = [];
  Customer? currentCustomer;
  final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm aa');
  StreamSubscription<Uint8List>? streamSubscription;
  bool isConnected = true;
  @override
  void initState() {
    dbHelper ??= DBHelper();
    limit = Singleton().limit;
    retriveCustomers();
    setDate();
    widget.connection.input!.listen(onDataReceived).onDone(() {
      if (mounted) {
        setState(() {
          isConnected = false;
        });
      }
    });
    FlutterBluetoothSerial.instance.onStateChanged().listen((event) {
      if (mounted) {
        if (event == BluetoothState.STATE_OFF) {
          showMessage(
              msg: 'Check your bluetooth!', color: Colors.red, duration: 1000);
          debugPrint('Check your bluetooth $event');
          BlocProvider.of<ConnectionCubit>(context).emitDisconnect();
          Navigator.pop(context);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (samples.isEmpty) {
          return true;
        }
        showDialog(
            context: context,
            builder: (builder) {
              return AlertDialog(
                title: const Text('Please confirm?'),
                content:
                    Text('Added ${samples.length} weight/s may not be saved.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Stay')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Leave'))
                ],
              );
            });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Weight'), actions: [
          !isConnected
              ? const Tooltip(
                  message: 'Device Disconnected',
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                  triggerMode: TooltipTriggerMode.tap,
                )
              : const Tooltip(
                  message: 'Device connected',
                  child: Icon(
                    Icons.bluetooth_connected,
                    color: Colors.blue,
                  ),
                  triggerMode: TooltipTriggerMode.tap,
                ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                        title: const Text(
                          'Select Limit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [300.0, 600.0, 1200.0].map((i) {
                          return ListTile(
                            title: Text("$i Gram",
                                style: i == limit
                                    ? const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold)
                                    : null),
                            trailing: i == limit
                                ? const Icon(
                                    Icons.done,
                                    color: Colors.blue,
                                  )
                                : null,
                            onTap: () async {
                              var prefs = await SharedPreferences.getInstance();
                              await prefs.setDouble("limit", i);
                              setState(() {
                                limit = i;
                                Singleton().limit = i;
                              });
                              Navigator.pop(context);
                            },
                          );
                        }).toList());
                  });
            },
            icon: const Icon(Icons.tune),
            tooltip: 'Adjust limit',
          ),
        ]),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Column(
                children: [
                  InkWell(
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      decoration: BoxDecoration(
                          color: isStarted ? Colors.grey.shade100 : null,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(100)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                                currentCustomer == null
                                    ? Icons.search_rounded
                                    : Icons.person_rounded,
                                color: Colors.grey),
                          ),
                          Text(
                            currentCustomer == null
                                ? 'Select Customer'
                                : currentCustomer!.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      if (!isConnected) {
                        showMessage(
                            msg:
                                'Please go back and CONNECT the device again !',
                            color: Colors.red,
                            duration: 1500);
                        return;
                      }
                      if (isStarted) {
                        showMessage(
                            msg:
                                'Please press STOP before changing the Customer !!!',
                            color: Colors.amber,
                            duration: 2000);
                        return;
                      }
                      if (customers.isEmpty) {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => const CustomerList()))
                            .then((value) => retriveCustomers());
                        return;
                      }
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
                              inputDecorationTheme: const InputDecorationTheme(
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
                              isThreeLine: true,
                              onTap: () {
                                Navigator.pop(context, customer);
                              },
                              leading: CircleAvatar(
                                  child: Text(customer.name.substring(0, 1))),
                              title: Text(customer.name),
                              subtitle: Text(
                                  'phone: ${customer.phone}\naadhaar: ${customer.aadhaar}'),
                            ),
                            suggestion: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person_add),
                                  title: const Text('Add new customer'),
                                  onTap: () {
                                    Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (builder) =>
                                                    const EditCustomer()))
                                        .then((value) {
                                      Navigator.pop(context);
                                      if (value != null) {
                                        showMessage(
                                            msg: 'Customer Added',
                                            color: Colors.green,
                                            duration: 1000);
                                      }

                                      retriveCustomers();
                                    });
                                  },
                                ),
                                Flexible(
                                  child: ListView.builder(
                                    itemCount: customers.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                          isThreeLine: true,
                                          onTap: () {
                                            Navigator.pop(
                                                context, customers[index]);
                                          },
                                          leading: CircleAvatar(
                                              child: Text(customers[index]
                                                  .name
                                                  .substring(0, 1))),
                                          title: Text(customers[index].name),
                                          subtitle: Text(
                                              'phone: ${customers[index].phone}\naadhaar: ${customers[index].aadhaar}'));
                                    },
                                  ),
                                ),
                              ],
                            ),
                            failure: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              child: const Text(
                                'No Customers found.\n Search using Customer\'s name, phone or aadhaar number',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            searchLabel: 'Search Customer',
                            filter: (customer) => [
                              customer.name,
                              customer.aadhaar,
                              customer.phone
                            ],
                            items: customers,
                          )).then((value) {
                        if (value == null) return;
                        debugPrint('${value.name} was selected');
                        setState(() {
                          currentCustomer = value;
                        });
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: StreamBuilder<int>(
                            stream: streamData,
                            initialData: 0,
                            builder: (context, snapshot) {
                              cValue = snapshot.data!;
                              return SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    maximum: limit,
                                    pointers: <GaugePointer>[
                                      RangePointer(
                                        value: cValue / divider,
                                        color: cValue / divider > limit
                                            ? Colors.red
                                            : null,
                                      )
                                    ],
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              cValue / divider <= limit
                                                  ? (cValue / divider)
                                                      .toStringAsFixed(
                                                          isThousand ? 2 : 3)
                                                  : "--OL--",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      cValue / divider > limit
                                                          ? Colors.red
                                                          : null),
                                            ),
                                            Text(
                                              cValue / divider <= limit
                                                  ? 'gram'
                                                  : 'Over limit',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      cValue / divider > limit
                                                          ? Colors.red
                                                          : null),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              );
                            }),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: ElevatedButton.icon(
                              onPressed: currentCustomer != null
                                  ? () {
                                      if (!isConnected) {
                                        showMessage(
                                            msg:
                                                'Please go back and CONNECT the device again !',
                                            color: Colors.red,
                                            duration: 1500);
                                        return;
                                      }
                                      setDate();
                                      if (!isStarted) {
                                        setState(() {
                                          isStarted = !isStarted;
                                        });
                                        showMessage(
                                            msg: 'Started',
                                            color: Colors.blue,
                                            duration: 1000);
                                      } else {
                                        setState(() {
                                          isStarted = !isStarted;
                                        });
                                        streamSink.add(0);
                                        showMessage(
                                            msg: 'Stopped',
                                            color: Colors.blue,
                                            duration: 1000);
                                      }
                                    }
                                  : null,
                              label: isStarted
                                  ? const Text('Stop')
                                  : const Text('Start'),
                              icon: isConnected
                                  ? isStarted
                                      ? const Icon(Icons.stop)
                                      : const Icon(Icons.play_arrow)
                                  : const Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                              style: ElevatedButton.styleFrom(
                                  primary: isConnected
                                      ? isStarted
                                          ? Colors.red
                                          : Colors.green
                                      : Colors.red),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: ElevatedButton.icon(
                              onPressed: isStarted
                                  ? () {
                                      if (!isConnected) {
                                        showMessage(
                                            msg:
                                                'Go back and connect the device !',
                                            color: Colors.red);
                                        return;
                                      }
                                      if (cValue / divider <= limit) {
                                        setState(() {
                                          samples.add(cValue);
                                          totalGram += cValue;
                                        });
                                      } else {
                                        showMessage(
                                            msg: 'Overwight',
                                            color: Colors.red,
                                            duration: 1000);
                                      }
                                    }
                                  : null,
                              // onPressed: () {
                              //   final r = Random();
                              //   var s = r.nextInt(100000);
                              //   setState(() {
                              //     samples.add(s);
                              //     totalGram += s;
                              //   });
                              // },
                              label: const Text('Add'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.blue),
                              icon: const Icon(
                                Icons.add,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ],
              )),
          sampleList(),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total : ${(totalGram / divider).toStringAsFixed(isThousand ? 2 : 3)} gram',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton(
                    onPressed: totalGram > 0.0
                        ? () {
                            setDate();
                            showDialog(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: const Text('Confirm to save'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(TextSpan(children: [
                                          const TextSpan(text: 'Total : '),
                                          TextSpan(
                                              text:
                                                  '${totalGram / divider} gram',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue))
                                        ])),
                                        Text.rich(TextSpan(children: [
                                          const TextSpan(text: 'Date : '),
                                          TextSpan(text: cdate)
                                        ])),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(color: Colors.red),
                                          )),
                                      TextButton(
                                          onPressed: () {
                                            saveTransaction();
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Save',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ))
                                    ],
                                  );
                                });
                          }
                        : null,
                    child: const Text('Save')),
              ],
            ),
          )
        ]),
      ),
    );
  }

  List<int> samples = [];
  Flexible sampleList() {
    return Expanded(
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: samples.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
                '${index + 1}) ${(samples[index] / divider).toStringAsFixed(isThousand ? 2 : 3)} gram'),
            tileColor: index % 2 == 0 ? Colors.grey.shade200 : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  totalGram -= samples[index];
                  samples.removeAt(index);
                });
              },
            ),
          );
        },
      ),
    );
  }

  void showMessage({required String msg, Color? color, int duration = 500}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      duration: Duration(milliseconds: duration),
    ));
  }

  void onDataReceived(Uint8List data) {
    if (!isStarted) return;
    String dataString = String.fromCharCodes(data);

    // ? Version 1 - First Device
    // var qList = dataString.split('\t');
    // for (String q in qList) {
    //   if (q.length == 8) {
    //     var a = q.substring(0, 6).replaceAll('.', '');
    //     var b = int.parse(a);
    //     streamSink.add(b);
    //   }
    // }

    // ? Version 2
    // var nums = dataString
    //     .replaceAll("][", " ")
    //     .replaceAll("[", "")
    //     .replaceAll("]", "");
    // var qList = nums.split(" ");
    // for (var q in qList) {
    //   if (q.length < 6) return;
    //   var pQ = int.tryParse(q);
    //   if (pQ != null) {
    //     try {
    //       if (!streamController.isClosed) {
    //         streamSink.add(pQ);
    //       }
    //     } catch (e) {
    //       debugPrint("at 611: pQ = $pQ, q = $q,\n$e");
    //     }
    //   } else {
    //     if (!streamController.isClosed) {
    //       streamSink.add((limit.toInt() * (isThousand ? 100 : 1000)) + 10);
    //     }
    //     debugPrint("at 615 q = $q, ${q.runtimeType}");
    //   }
    // }
    // ? Version 3

    var nums = dataString
        .replaceAll(String.fromCharCode(13), '')
        .replaceAll('\n', '')
        .replaceAll('.', '')
        .trim();
    var qList = nums.split(" ");
    for (var q in qList) {
      if (q.length != 6) return;
      if (q[5] != '0' && q[0] == '0') {
        if (!streamController.isClosed) {
          streamSink.add((limit.toInt() * (isThousand ? 100 : 1000)) + 10);
        }
        return;
      }
      var pQ = int.tryParse(q);
      // Todo = Ask for over limit condition
      debugPrint('q = $q pQ = $pQ');
      try {
        if (!streamController.isClosed) {
          streamSink.add(pQ!);
        }
      } catch (e) {
        debugPrint("at 638: pQ = $pQ, q = $q,\n$e");
      }
    }
  }

  Future<void> retriveCustomers() async {
    dbHelper!.getCustomers().then((value) {
      setState(() {
        customers = value;
      });
    });
  }

  void setDate() {
    DateTime now = DateTime.now();
    setState(() {
      cdate = formatter.format(now);
    });
  }

  void saveTransaction() {
    if (currentCustomer == null) {
      showMessage(
          msg: 'Please select one Customer',
          color: Colors.black,
          duration: 700);
      return;
    }
    try {
      var tx = TransactionX(
          customerName: currentCustomer!.name,
          customerID: currentCustomer!.uid,
          weight: (totalGram / divider).toStringAsFixed(isThousand ? 2 : 3),
          date: cdate);
      dbHelper!.addTransaction(tx);
      showMessage(msg: 'Saving weight...', color: Colors.green);
      setState(() {
        totalGram = 0;
        samples.clear();
      });
    } catch (e) {
      showMessage(msg: 'Can\'t save', color: Colors.red, duration: 800);
      debugPrint('can\'t save transaction');
    }
  }
}
