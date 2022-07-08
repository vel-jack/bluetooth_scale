Obx(() {
          if (bluetoothController.state.value == BluetoothState.STATE_ON) {
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
          } else {
            return BluetoothOffWidget(onPressed: () {
              bluetoothController.enableBluetooth();
            });
          }
        }));