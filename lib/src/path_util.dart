import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:windows_documents/windows_documents.dart';

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
  } else if (Platform.isMacOS) {
    return (await getDownloadsDirectory()).path + '/bitter';
  } else {
    return (await getExternalStorageDirectories(type: StorageDirectory.downloads)).first.path;
  }
}

Future<String> getLogPath() async {
  if (Platform.isWindows) {
    return (await getDocumentsDirectory()) + '/bitter/log';
  } else if (Platform.isMacOS) {
    return (await getDownloadsDirectory()).path + '/bitter/log';
  } else {
    return (await getApplicationDocumentsDirectory()).path + '/log';
  }
}
