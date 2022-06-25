part of 'ble_status_cubit.dart';

abstract class BleState {}

class BleStatusLoading extends BleState {}

class BleOnState extends BleState {}

class BleOffState extends BleState {}


  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;

  //   return other is BleConnected && other.connection == connection;
  // }

  // @override
  // int get hashCode => connection.hashCode;