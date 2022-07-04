import 'package:flutter/material.dart';

class BluetoothOff extends StatelessWidget {
  const BluetoothOff({Key? key, required this.onPressed}) : super(key: key);
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'PLEASE TURN ON BLUETOOTH FIRST',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      FloatingActionButton.large(
        onPressed: onPressed,
        child: const Icon(Icons.bluetooth),
      ),
      const SizedBox(height: 50),
    ]);
  }
}
