import 'dart:io';
import 'package:bluetooth_scale/pages/customer/customer_list.dart';
import 'package:bluetooth_scale/utils/constants.dart';
import 'package:bluetooth_scale/widgets/owner_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bluetooth_scale/utils/pdf_api.dart';
import 'package:bluetooth_scale/utils/pdf_invoice_api.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('ddMMyyyyhhmmss');
    return ListView(
      children: [
        const OwnerHeaderWidget(),
        ListTile(
          title: const Text('Customers'),
          leading: const Icon(Icons.people),
          onTap: () {
            Get.to(() => const CustomerList());
          },
        ),
        ListTile(
          onTap: () async {
            if (await Permission.storage.request().isGranted) {
              try {
                var dir = Directory(filePath);
                if (!await dir.exists()) {
                  await dir.create(recursive: true);
                }
                final pdf = await PdfInvoiceApi.generateCompleteData(
                    '$filePath/CompleteDetails_${formatter.format(DateTime.now())}.pdf');
                await PdfApi.openFile(pdf);

                // ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text('Exported to Downloads')));
                Get.snackbar('Exported', 'Exported to Downloads');
                // await pdf.copy(
                //     '/storage/emulated/0/Download/CompleteDetail${formatter.format(DateTime.now())}.pdf');
              } catch (e) {
                debugPrint('Something happened...\n$e');

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Failed to export'),
                  backgroundColor: Colors.red,
                ));
              }
            }
          },
          title: const Text('Export to PDF'),
          leading: const Icon(Icons.picture_as_pdf),
        ),
        ListTile(
          onTap: () {},
          title: const Text('Check for updates'),
          leading: const Icon(Icons.update),
        ),
        ListTile(
          onTap: () async {
            if (!await launchUrl(Uri.parse("https://www.bioz.in"))) {
              throw 'Can\'t open url';
            }
          },
          title: const Text('Visit our website'),
          leading: const Icon(Icons.language),
        ),
        ListTile(
          title: const Text('Contact Us'),
          leading: const Icon(Icons.message),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  tooltip: 'Call',
                  onPressed: () async {
                    if (!await launchUrl(Uri.parse('tel:9345967705'))) {
                      throw 'Can\'t open url';
                    }
                  },
                  color: Colors.blue,
                  icon: const Icon(Icons.call)),
              IconButton(
                  tooltip: 'Mail',
                  onPressed: () async {
                    if (!await launchUrl(Uri.parse('mailto:bioz@outlook.in'))) {
                      throw 'Can\'t open url';
                    }
                  },
                  color: Colors.blue,
                  icon: const Icon(
                    Icons.email,
                  ))
            ],
          ),
        ),
      ],
    );
  }
}
