import 'package:bluetooth_scale/model/customer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerWidget extends StatelessWidget {
  const CustomerWidget({Key? key, required this.customer, required this.onEdit})
      : super(key: key);
  final Customer customer;
  final VoidCallback onEdit;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              radius: 60,
              child: Text(
                customer.name.substring(0, 1).toUpperCase(),
                style:
                    const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  customer.name.length > 13
                      ? customer.name.substring(0, 13) + '...'
                      : customer.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'ID : ${customer.uid}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              ButtonBar(
                children: [
                  ElevatedButton.icon(
                      icon: const Icon(Icons.call),
                      onPressed: () =>
                          launchUrl(Uri.parse('tel:${customer.phone}')),
                      label: const Text('Call')),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                      label: const Text('Edit')),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
