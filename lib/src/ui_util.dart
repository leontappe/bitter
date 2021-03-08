import 'dart:io';

import 'package:bitter/src/path_util.dart';
import 'package:flutter/material.dart';

Future<void> onSaveBill(BuildContext context, String filename, List<int> bytes) async {
  var file = File('${await getDataPath()}/$filename.pdf');
  if (await file.exists()) {
    var i = 2;
    file = File('${await getDataPath()}/$filename $i.pdf');
    while (await file.exists()) {
      i++;
      file = File('${await getDataPath()}/$filename $i.pdf');
    }
  }
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Die Rechnung wurde erfolgreich unter ${file.path} abgespeichert.'),
    duration: const Duration(seconds: 5),
  ));
}