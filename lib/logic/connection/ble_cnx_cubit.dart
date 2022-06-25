import 'dart:async';

import 'package:bluetooth_scale/logic/ble_status/ble_status_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

part 'ble_cnx_state.dart';

class ConnectionCubit extends Cubit<ConnectState> {
  final BleStatusCubit bleStatusCubit;
  StreamSubscription? streamSubscription;
  ConnectionCubit({required this.bleStatusCubit}) : super(BleUnknown()) {
    streamSubscription = bleStatusCubit.stream.listen((event) {
      if (event is BleOffState) {
        emit(BleDisconnected());
      }
    });
  }

  Future<void> connect(BluetoothDevice _device) async {
    emit(BleConnecting());
    try {
      BluetoothConnection.toAddress(_device.address).then((connection) {
        emit(BleConnected(connection));
        connection.input!.listen(null).onDone(() {
          emit(BleDisconnected());
        });
      }).catchError((onError) {
        emit(BleConnectionError());
      });
    } catch (e) {
      emit(BleConnectionError());
    }
  }

  void emitDisconnect() {
    emit(BleDisconnected());
  }

  void emitFresh() {
    emit(BleUnknown());
  }

  @override
  Future<void> close() {
    streamSubscription?.cancel();
    return super.close();
  }
}
