import 'package:bluetooth_scale/utils/constants.dart';
import 'package:bluetooth_scale/widgets/bluetooth_off.dart';
import 'package:bluetooth_scale/widgets/onscreen_loaded.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({Key? key}) : super(key: key);

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Paired Devices'),
          actions: [
            IconButton(
              onPressed: () {
                bluetoothController.getPairedDevices();
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload devices',
            ),
            IconButton(
              onPressed: () {
                openAppSettings();
              },
              icon: const Icon(Icons.settings),
              tooltip: 'Open Settings',
            )
          ],
        ),
        body: Obx(() {
          if (bluetoothController.state.value == BluetoothState.STATE_ON) {
            bluetoothController.getPairedDevices();
            return Stack(
              children: [
                Column(
                  children: [
                    Flexible(
                      child: ListView.separated(
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                        ),
                        itemCount: bluetoothController.devices.value.length,
                        itemBuilder: (BuildContext context, int index) {
                          final device =
                              bluetoothController.devices.value[index];
                          if (bluetoothController.connectedDevice.value ==
                              device) {
                            return ListTile(
                              textColor: Colors.blue,
                              horizontalTitleGap: 0,
                              leading: const Icon(
                                Icons.bluetooth_connected,
                                color: Colors.blue,
                              ),
                              title: Text('${device.name}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue)),
                              trailing: IconButton(
                                  onPressed: () {
                                    bluetoothController.disconnect();
                                  },
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  )),
                            );
                          } else {
                            return ListTile(
                              horizontalTitleGap: 0,
                              leading: const Icon(Icons.bluetooth),
                              title: Text('${device.name}'),
                              onTap:
                                  bluetoothController.connectedDevice.value ==
                                          null
                                      ? () {
                                          bluetoothController
                                              .connectToDevice(device);
                                        }
                                      : null,
                            );
                          }
                        },
                      ),
                    ),
                    ListTile(
                      textColor: Colors.blue,
                      tileColor: Colors.grey.shade100,
                      title: const Text(
                        'Click here to pair new device',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(
                        Icons.arrow_right,
                        color: Colors.blue,
                      ),
                      onTap: () {
                        FlutterBluetoothSerial.instance.openSettings();
                      },
                    ),
                  ],
                ),
                if (bluetoothController.isConnecting.value)
                  const OnScreenLoader(),
              ],
            );
          }
          return BluetoothOffWidget(onPressed: () {
            bluetoothController.enableBluetooth();
          });
        }));
  }
}
