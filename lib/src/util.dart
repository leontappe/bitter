import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:windows_documents/windows_documents.dart';

final dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');
final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');
final filenameDateFormat = DateFormat('yyMMdd', 'de_DE');

String formatFilenameDate(DateTime date) => filenameDateFormat.format(date);
String formatDate(DateTime date) => dateFormat.format(date);
String formatDateTime(DateTime date) => dateTimeFormat.format(date);

String formatFigure(int value) => (value / 100.0).toStringAsFixed(2).replaceAll('.', ',') + ' €';

Future<String> getConfigPath() async {
  String path;
  if (Platform.isWindows) {
    path = await getDocumentsDirectory();
  } else {
    path = (await getApplicationDocumentsDirectory()).path;
  }

  if (Platform.isWindows) {
    return path + '/bitter/config';
  } else {
    return path + '/bitter';
  }
}

Future<String> getDataPath() async {
  if (Platform.isWindows) {
    return (await getDocumentsDirectory()) + '/bitter';
  } else {
    return (await getDownloadsDirectory()).path + '/bitter';
  }
}

Future<String> getLogPath() async {
  if (Platform.isWindows) {
    return (await getDocumentsDirectory()) + '/bitter/log';
  } else {
    return (await getDownloadsDirectory()).path + '/bitter/log';
  }
}

Future<void> onSaveBill(BuildContext context, String filename, List<int> bytes) async {
  var file = File('${await getDataPath()}/${filename}.pdf');
  if (await file.exists()) {
    var i = 2;
    file = File('${await getDataPath()}/${filename} $i.pdf');
    while (await file.exists()) {
      i++;
      file = File('${await getDataPath()}/${filename} $i.pdf');
    }
  }
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);
  await ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Die Rechnung wurde erfolgreich unter ${file.path} abgespeichert.'),
    duration: const Duration(seconds: 5),
  ));
}

int parseFloat(String input) {
  final split = input.replaceAll(',', '.').split('.');
  return (int.parse(split.first) * 100) +
      ((split.length > 1)
          ? int.parse((split.last.length > 1) ? split.last.substring(0, 2) : split.last + '0')
          : 0);
}
