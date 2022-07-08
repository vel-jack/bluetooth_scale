import 'dart:async';

import 'dart:typed_data';
import 'package:bluetooth_scale/controller/search_controller.dart';
import 'package:bluetooth_scale/model/customer.dart';
import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:bluetooth_scale/pages/customer/edit_customer.dart';
import 'package:bluetooth_scale/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class AddScale extends StatefulWidget {
  const AddScale({Key? key}) : super(key: key);

  @override
  _AddScaleState createState() => _AddScaleState();
}

class _AddScaleState extends State<AddScale> {
  int totalGram = 0;
  bool isStarted = false;
  int cValue = 0;
  bool isThousand = false;
  double limit = 600.0;
  double divider = 1000.0;
  String _time = '';

  StreamController<int> streamController = StreamController<int>();
  StreamSink<int> get streamSink => streamController.sink;
  Stream<int> get streamData => streamController.stream;
  Customer? currentCustomer;
  final DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm aa');
  StreamSubscription<Uint8List>? streamSubscription;

  @override
  void initState() {
    streamSubscription =
        bluetoothController.connection!.input!.listen(onDataReceived);
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
        appBar: AppBar(
          title: const Text('Add Weight'),
        ),
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
                      if (!bluetoothController.isConnected) {
                        showMessage(
                          'Device disconnect',
                          'Please go back and CONNECT the device again !',
                          color: Colors.red,
                        );
                        return;
                      }
                      if (isStarted) {
                        showMessage(
                          'Attention',
                          'Please press STOP before changing the Customer !!!',
                          color: Colors.amber,
                        );
                        return;
                      }
                      if (customerController.customers.isEmpty) {
                        showMessage(
                          'No customer selected',
                          'Please select a customer to start',
                        );
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => const EditCustomer()))
                            .then((value) {
                          setState(() {
                            if (value != null) {
                              currentCustomer = value;
                            }
                          });
                        });
                        return;
                      }
                      showSearch(
                              context: context,
                              delegate:
                                  search(context, customerController.customers))
                          .then((value) {
                        if (value != null) {
                          setState(() {
                            currentCustomer = value;
                          });
                        }
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
                                      if (!bluetoothController.isConnected) {
                                        showMessage(
                                          'Device disconnected',
                                          'Please go back and CONNECT the device again !',
                                          color: Colors.red,
                                        );
                                        return;
                                      }
                                      if (!isStarted) {
                                        setState(() {
                                          isStarted = !isStarted;
                                        });
                                        showMessage(
                                          'Started..',
                                          '',
                                          color: Colors.blue,
                                        );
                                      } else {
                                        setState(() {
                                          isStarted = !isStarted;
                                        });
                                        streamSink.add(0);
                                        showMessage(
                                          'Stopped..',
                                          '',
                                          color: Colors.blue,
                                        );
                                      }
                                    }
                                  : null,
                              label: isStarted
                                  ? const Text('Stop')
                                  : const Text('Start'),
                              icon: bluetoothController.isConnected
                                  ? isStarted
                                      ? const Icon(Icons.stop)
                                      : const Icon(Icons.play_arrow)
                                  : const Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                              style: ElevatedButton.styleFrom(
                                  primary: bluetoothController.isConnected
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
                                      if (!bluetoothController.isConnected) {
                                        showMessage(
                                          'Device disconnected',
                                          'Please go back and CONNECT the device again !',
                                          color: Colors.red,
                                        );
                                        return;
                                      }
                                      if (cValue / divider <= limit) {
                                        setState(() {
                                          samples.add(cValue);
                                          totalGram += cValue;
                                        });
                                      } else {
                                        showMessage(
                                          'Over weight',
                                          'Current weight exceeded the limit !',
                                          color: Colors.red,
                                        );
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
                                          TextSpan(text: getTime())
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

  void showMessage(String title, String msg, {Color? color}) {
    Get.snackbar(title, msg, leftBarIndicatorColor: color);
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
      // debugPrint('q = $q pQ = $pQ');
      try {
        if (!streamController.isClosed) {
          streamSink.add(pQ!);
        }
      } catch (_) {
        // debugPrint("at 638: pQ = $pQ, q = $q,\n$e");
      }
    }
  }

  String getTime() {
    DateTime now = DateTime.now();
    _time = formatter.format(now);
    return _time;
  }

  void saveTransaction() {
    if (currentCustomer == null) {
      showMessage(
        'No customer selected',
        'Please select a customer to save',
      );

      return;
    }
    try {
      var tx = TransactionX(
          customerName: currentCustomer!.name,
          customerID: currentCustomer!.uid,
          weight: (totalGram / divider).toStringAsFixed(isThousand ? 2 : 3),
          date: _time);
      transactionController.addTransaction(tx);
      showMessage('Saved', 'Saved succesfully', color: Colors.green);
      setState(() {
        totalGram = 0;
        samples.clear();
      });
    } catch (e) {
      showMessage('Can\'t save', 'Something went wrong while saving',
          color: Colors.red);
      // debugPrint('can\'t save transaction');
    }
  }
}
