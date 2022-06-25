import 'dart:io';

import 'package:flutter/material.dart' as x;
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File> saveDoc({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();
    // final dir = await getExternalStorageDirectory();

    final file = File(name);
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    try {
      await OpenFile.open(url);
    } catch (e) {
      x.debugPrint('Something happened...!!!\n$e');
    }
  }
}
