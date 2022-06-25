import 'package:bluetooth_scale/model/transactionx.dart';
import 'package:flutter/material.dart';
import 'package:search_page/search_page.dart';

import '../db/db_helper.dart';
import 'customer/customer_profile.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({Key? key, required this.transactions})
      : super(key: key);
  final List<TransactionX> transactions;

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  DBHelper? dbHelper;
  List<TransactionX> transactions = [];
  @override
  void initState() {
    dbHelper ??= DBHelper();
    transactions = widget.transactions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: SearchPage<TransactionX>(
                        barTheme: Theme.of(context).copyWith(
                          textTheme: Theme.of(context).textTheme.copyWith(
                                headline6: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                          inputDecorationTheme: const InputDecorationTheme(
                            hintStyle: TextStyle(
                              color: Colors.black38,
                              fontSize: 20,
                            ),
                            focusedErrorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            border: InputBorder.none,
                          ),
                        ),
                        failure: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No matching history found, Please try different',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        suggestion: const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Search using customer name, customer id, date or weight',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        builder: (transaction) => ListTile(
                              onTap: () async {
                                Navigator.pop(context);
                                await DBHelper()
                                    .getCustomerByID(transaction.customerID)
                                    .then((customerx) {
                                  if (customerx != null) {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (builder) {
                                      return CustomerProfile(
                                          customer: customerx);
                                    })).then((value) => refreshList());
                                  }
                                });
                              },
                              leading: CircleAvatar(
                                  backgroundColor: Colors.grey.shade100,
                                  child: Text(
                                    transaction.customerName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )),
                              title: Text(
                                transaction.customerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text.rich(TextSpan(children: [
                                const TextSpan(
                                    text: 'Date : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: transaction.date.substring(0, 10))
                              ])),
                              trailing: Text('${transaction.weight} g'),
                            ),
                        filter: (transaction) => [
                              transaction.date,
                              transaction.customerName,
                              transaction.customerID,
                              transaction.weight
                            ],
                        items: transactions));
              },
              tooltip: 'Search Sale item',
              icon: const Icon(Icons.search))
        ],
      ),
      body: ListView.builder(
        itemCount: transactions.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == transactions.length) {
            return const ListTile();
          }
          return ListTile(
            tileColor: index % 2 == 0 ? Colors.grey.shade100 : null,
            title: Text(
              transactions[index].customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: CircleAvatar(
                backgroundColor:
                    index % 2 == 0 ? Colors.white : Colors.grey.shade100,
                child: Text(
                  transactions[index]
                      .customerName
                      .substring(0, 1)
                      .toUpperCase(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                )),
            subtitle: Text.rich(TextSpan(children: [
              const TextSpan(
                  text: 'Date : ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: transactions[index].date.substring(0, 10))
            ])),
            // Text(data[index].date.substring(0, 10)),
            trailing: Text('${transactions[index].weight} g'),
            onTap: () async {
              await DBHelper()
                  .getCustomerByID(transactions[index].customerID)
                  .then((customerx) {
                if (customerx != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (builder) {
                    return CustomerProfile(customer: customerx);
                  })).then((value) => refreshList());
                }
              });
            },
          );
        },
      ),
    );
  }

  Future<void> refreshList() async {
    List<TransactionX> temp = await dbHelper!.getAllTx();
    setState(() {
      transactions = temp;
    });
  }
}
