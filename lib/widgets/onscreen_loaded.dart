import 'package:flutter/material.dart';

class OnScreenLoader extends StatelessWidget {
  const OnScreenLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
