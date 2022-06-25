import 'package:bluetooth_scale/logic/ble_devices/devices_cubit.dart';
import 'package:bluetooth_scale/logic/ble_status/ble_status_cubit.dart';
import 'package:bluetooth_scale/logic/connection/ble_cnx_cubit.dart';
import 'package:bluetooth_scale/pages/home.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class SelectDevice extends StatefulWidget {
  const SelectDevice({Key? key}) : super(key: key);

  @override
  State<SelectDevice> createState() => _SelectDeviceState();
}

class _SelectDeviceState extends State<SelectDevice> {
  @override
  void initState() {
    listenBluetoothState();
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
    return BlocBuilder<BleStatusCubit, BleState>(builder: (cxt, state) {
      var _isOn = false;
      if (state is BleOnState) {
        _isOn = true;
      } else if (state is BleOffState) {
        _isOn = false;
      }
      return _isOn ? selectDevice(context) : bluetoothOff();
    });
  }

  Widget selectDevice(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Device'),
        actions: [
          TextButton.icon(
              onPressed: () async {
                BlocProvider.of<DevicesListCubit>(context).getPairedDevices();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reload')),
          if (!Navigator.canPop(context))
            TextButton(
                onPressed: () async {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const HomePage()));
                  }
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ))
        ],
      ),
      body: BlocBuilder<ConnectionCubit, ConnectState>(
          buildWhen: (previous, current) {
        return previous != current;
      }, builder: (ctx, state) {
        var isConnecting = false;
        if (state is BleConnecting) {
          isConnecting = true;
        } else if (state is BleConnected) {
          isConnecting = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Connected'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ));
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          });
        } else {
          isConnecting = false;
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                Flexible(
                  child: BlocBuilder<DevicesListCubit, DevicesListState>(
                      builder: (context, state) {
                    if (state is ListLoaded) {
                      return ListView.separated(
                        separatorBuilder: (context, index) => const Divider(
                          height: 0,
                          thickness: 1,
                          indent: 20,
                          endIndent: 10,
                        ),
                        itemCount: state.devices.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: const Icon(Icons.bluetooth),
                            // tileColor:
                            //     index % 2 == 0 ? Colors.grey.shade100 : null,
                            title: Text('${state.devices[index].name}'),
                            onTap: () {
                              BlocProvider.of<ConnectionCubit>(context)
                                  .connect(state.devices[index]);
                            },
                          );
                        },
                      );
                    }
                    return const LinearProgressIndicator();
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      const Text('Can\'t find your device?'),
                      TextButton(
                          onPressed: () {
                            FlutterBluetoothSerial.instance.openSettings();
                          },
                          child: const Text(
                            'Open Settings',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                )
              ],
            ),
            if (isConnecting)
              Container(
                color: Colors.white60,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10)),
                          child: const CircularProgressIndicator()),
                      const Text(
                        'Connecting',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 100)
                    ],
                  ),
                ),
              )
          ],
        );
      }),
    );
  }

  Widget bluetoothOff() {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!Navigator.canPop(context))
            TextButton(
                onPressed: () async {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => const HomePage()));
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ))
        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'PLEASE TURN ON BLUETOOTH FIRST',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          FloatingActionButton.large(
            onPressed: () {
              enableBluetooth(context);
            },
            child: const Icon(Icons.bluetooth),
          ),
        ]),
      ),
    );
  }

  Future<void> enableBluetooth(context) async {
    try {
      FlutterBluetoothSerial.instance.ensurePermissions();
      FlutterBluetoothSerial.instance.requestEnable().then((value) {
        if (value == true) {
          BlocProvider.of<BleStatusCubit>(context).emitOn();
        }
      });
    } catch (e) {
      debugPrint('Error Occured\n$e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Unable to turn on')));
    }
  }
}
