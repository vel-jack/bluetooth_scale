import 'dart:developer';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController {
  static BluetoothController instance = Get.find();
  final Rx<BluetoothState> state = BluetoothState.STATE_OFF.obs;
  final Rx<List<BluetoothDevice>> devices = Rx<List<BluetoothDevice>>([]);
  final Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  BluetoothConnection? connection;
  final Rx<bool> isConnecting = false.obs;
  bool get isConnected => connectedDevice.value != null ? true : false;
  @override
  void onInit() {
    FlutterBluetoothSerial.instance.state.then((value) {
      state.value = value;
    });
    state.bindStream(FlutterBluetoothSerial.instance.onStateChanged());
    ever(state, _onStateChanged);
    super.onInit();
  }

  _onStateChanged(BluetoothState callback) {
    log(callback.toString(), name: 'BluetoothState');
    if (callback == BluetoothState.STATE_OFF) {
      if (connection != null) {
        connection!.close();
        connectedDevice.value = null;
      }
    }
  }

  void getPairedDevices() async {
    // if (await checkPermissions()) {
    // await requestPermissions();
    try {
      await FlutterBluetoothSerial.instance.ensurePermissions();
      devices.value = await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      if (await Permission.location.isDenied) {
        log('LOCATION PERMISSION : $e', name: 'getPairedDevices');
        showMessage('Location Permission !',
            'Please allow location permission in App settings');
      }
      if (await Permission.bluetooth.isDenied) {
        log('BLUETOOTH PERMISSION  $e', name: 'getPairedDevices');
        showMessage('Bluetooth Permission !',
            'Please allow bluetooth permission in App settings');
      }
    }
    // } else {
    //   showMessage('No permissions available',
    //       'Please allow permissions in App Settings');
    // }
  }

  void connectToDevice(BluetoothDevice _device) async {
    try {
      isConnecting.value = true;
      BluetoothConnection.toAddress(_device.address).then((cnx) {
        connection = cnx;
        connectedDevice.value = _device;
        showMessage('Connected', 'Device connected successfully');
        isConnecting.value = false;

        cnx.input!.listen(null).onDone(() {
          connection = null;
          connectedDevice.value = null;
        });
      }).catchError((onError) {
        isConnecting.value = false;
        log('$onError', name: "ConnectToDevice");
        showMessage('Something went wrong', 'Can\'t connect with the device');
      });
    } catch (e) {
      log('$e', name: 'ConnectToDevice - Connect');
      isConnecting.value = false;
    }
  }

  void disconnect() async {
    try {
      await connection!.close();
      showMessage('Disconnected', '');
    } catch (e) {
      log('$e', name: 'disconnect');
      showMessage('Something went wrong', 'Can\'t disconnect device');
    }
  }

  void enableBluetooth() async {
    // await requestPermissions();
    try {
      await FlutterBluetoothSerial.instance.ensurePermissions();
      await FlutterBluetoothSerial.instance.requestEnable();
    } catch (e) {
      log('$e');
    }
  }

  // Future<bool> checkPermissions() async {
  //   if (await Permission.location.isPermanentlyDenied) {
  //     return false;
  //   } else if (await Permission.bluetooth.isPermanentlyDenied) {
  //     return false;
  //   }
  //   return true;
  // }

  // Future<void> requestPermissions() async {
  //   try {
  //     await Permission.location.request();
  //   } catch (_) {}
  // }

  void showMessage(String title, String msg, {sec = 2}) {
    Get.snackbar(title, msg,
        animationDuration: const Duration(milliseconds: 500),
        duration: Duration(seconds: sec));
  }

  @override
  void onClose() {
    connection!.close();
    super.onClose();
  }
}
