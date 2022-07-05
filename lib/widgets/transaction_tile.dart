import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    Key? key,
    required this.transaction,
    required this.index,
    required this.onPressed,
  }) : super(key: key);

  final TransactionX transaction;
  final int index;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: index % 2 == 0 ? Colors.grey.shade100 : null,
      title: Text(
        transaction.customerName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: CircleAvatar(
          backgroundColor: index % 2 == 0 ? Colors.white : Colors.grey.shade100,
          child: Text(
            transaction.customerName.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )),
      subtitle: Text.rich(TextSpan(children: [
        const TextSpan(
            text: 'Date : ', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(text: transaction.date.substring(0, 10))
      ])),
      // Text(data[index].date.substring(0, 10)),
      trailing: Text('${transaction.weight} g'),
      onTap: onPressed,
    );
  }
}
