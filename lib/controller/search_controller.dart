import 'package:bluetooth_scale/model/customer.dart';
import 'package:flutter/material.dart';
import 'package:search_page/search_page.dart';

SearchPage<Customer> search(BuildContext context, List<Customer> customers) {
  return SearchPage<Customer>(
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
    builder: (customer) => ListTile(
      leading: CircleAvatar(
          child: Text(
        customer.name.substring(0, 1).toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      )),
      title: Text(
        customer.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text('phone: ${customer.phone}\naadhaar: ${customer.aadhaar}'),
      onTap: () {
        Navigator.pop(context, customer);
      },
    ),
    suggestion: ListView.builder(
      itemCount: customers.length,
      itemBuilder: (BuildContext context, int index) {
        Customer customer = customers[index];
        return ListTile(
          leading: CircleAvatar(
              child: Text(
            customer.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
          title: Text(
            customer.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle:
              Text('phone: ${customer.phone}\naadhaar: ${customer.aadhaar}'),
          onTap: () {
            Navigator.pop(context, customer);
          },
        );
      },
    ),
    failure: const Padding(
      padding: EdgeInsets.all(20.0),
      child: Text(
        'No matching customer found, Search your customers using NAME, AADHAAR, PHONE ',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    filter: (customer) => [customer.name, customer.aadhaar, customer.phone],
    items: customers,
    searchLabel: 'Search Customer',
  );
}
