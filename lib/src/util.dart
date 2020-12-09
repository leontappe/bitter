import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:windows_documents/windows_documents.dart';

String formatDate(DateTime date) {
  return DateFormat('dd.MM.yyyy', 'de_DE').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('dd.MM.yyyy HH:mm', 'de_DE').format(date);
}

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

int parseFloat(String input) {
  final split = input.replaceAll(',', '.').split('.');
  return (int.parse(split.first) * 100) +
      ((split.length > 1)
          ? int.parse((split.last.length > 1) ? split.last.substring(0, 2) : split.last + '0')
          : 0);
}
