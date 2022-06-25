part of 'ble_cnx_cubit.dart';

abstract class ConnectState {}

class BleUnknown extends ConnectState {}

class BleConnected extends ConnectState {
  BluetoothConnection? connection;
  BleConnected(this.connection);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BleConnected && other.connection == connection;
  }

  @override
  int get hashCode => connection.hashCode;
}

class BleDisconnected extends ConnectState {}

class BleConnecting extends ConnectState {}

class BleConnectionError extends ConnectState {}
