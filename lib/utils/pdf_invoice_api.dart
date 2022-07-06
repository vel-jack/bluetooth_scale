import 'dart:io';
import 'package:bluetooth_scale/db/db_helper.dart';
import 'package:bluetooth_scale/utils/constants.dart';
import 'package:bluetooth_scale/utils/pdf_api.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../model/customer.dart';
import '../model/transactionx.dart';

class PdfInvoiceApi {
  static Future<File> generate(
      {required String loc,
      required Customer customer,
      required List<TransactionX> transactions}) async {
    Widget sellerDetails() {
      return Row(children: [
        Expanded(
            flex: 4,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ownerController.owner.business,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text('Phone : +91-${ownerController.owner.phone}'),
              Text('Email : ${ownerController.owner.email}'),
              Divider()
            ])),
        Expanded(flex: 6, child: SizedBox())
      ]);
    }

    Widget customerDetail() {
      return Row(children: [
        Expanded(
            flex: 4,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Customer Detail : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Name\t :${customer.name}'),
              Text('Phone\t :${customer.phone}'),
              Text('Aadhar\t :${customer.aadhaar}'),
              Row(
                  children: [Text('Address \t:'), Text(customer.address)],
                  crossAxisAlignment: CrossAxisAlignment.start)
            ])),
        Expanded(flex: 6, child: SizedBox())
      ]);
    }

    Widget transactionTable() {
      final headers = ['Date', 'wt/gram', 'price/Rs'];
      final data = transactions.map((tx) {
        return [tx.date, '${tx.weight} g', 'Rs.0.0'];
      }).toList();
      return Table.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        headerStyle: TextStyle(fontWeight: FontWeight.bold),
        headerDecoration: const BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.centerRight,
          2: Alignment.centerRight
        },
      );
    }

    final font = await rootBundle.load('assets/OpenSans.ttf');
    final pdf = Document(
        theme: ThemeData(defaultTextStyle: TextStyle(font: Font.ttf(font))));
    pdf.addPage(MultiPage(
        build: (build) => [
              sellerDetails(),
              customerDetail(),
              Divider(),
              SizedBox(height: 10),
              Text('Purchase History :',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              transactionTable()
            ]));

    return PdfApi.saveDoc(name: loc, pdf: pdf);
  }

  static Future<File> generateCompleteData(String loc) async {
    final font = await rootBundle.load('assets/OpenSans.ttf');
    List<TransactionX> transactions = await DBHelper().getAllTx();
    List<Customer> customers = await DBHelper().getCustomers();
    customers.sort((a, b) => a.name.compareTo(b.name));
    Widget transactionTable() {
      final headers = ['Customer', 'Customer ID', 'Date', 'wt/gram'];
      final data = transactions.map((tx) {
        return [tx.customerName, tx.customerID, tx.date, '${tx.weight} g'];
      }).toList();
      return Table.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        headerStyle: TextStyle(fontWeight: FontWeight.bold),
        headerDecoration: const BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.centerLeft,
          2: Alignment.centerLeft,
          3: Alignment.centerRight
        },
      );
    }

    Widget customerTable() {
      final headers = ['Name', 'Customer ID', 'Aadhar', 'Phone'];
      final data = customers.map((customer) {
        return [customer.name, customer.uid, customer.aadhaar, customer.phone];
      }).toList();
      return Table.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        headerStyle: TextStyle(fontWeight: FontWeight.bold),
        headerDecoration: const BoxDecoration(color: PdfColors.grey300),
        cellAlignments: {
          0: Alignment.centerLeft,
          1: Alignment.centerLeft,
          2: Alignment.centerLeft,
          3: Alignment.centerLeft
        },
      );
    }

    final pdf = Document(
        theme: ThemeData(defaultTextStyle: TextStyle(font: Font.ttf(font))));
    pdf.addPage(MultiPage(
        build: (build) => [
              Text('Customers : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              customerTable(),
              SizedBox(height: 10),
              Text('Sale history : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              transactionTable(),
            ]));
    return PdfApi.saveDoc(name: loc, pdf: pdf);
  }
}
