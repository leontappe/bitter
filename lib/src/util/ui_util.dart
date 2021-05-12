import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

import 'path_util.dart';

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
    action: SnackBarAction(
      label: 'Öffnen',
      onPressed: () => OpenFile.open(file.path),
      textColor: Colors.white,
    ),
    duration: const Duration(seconds: 5),
  ));
}
