import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:windows_documents/windows_documents.dart';

import '/environment_config.dart';

Future<String> getConfigPath() async {
  String path;
  if (Platform.isWindows) {
    path = await getDocumentsDirectory();
  } else {
    path = (await getApplicationDocumentsDirectory()).path;
  }

  if (Platform.isWindows) {
    path = path + '/bitter/config';
  } else {
    path = path + '/bitter';
  }

  if (EnvironmentConfig.debug) {
    return path + '/debug';
  }
  return path;
}

Future<String> getDataPath() async {
  String path;
  if (Platform.isWindows) {
    path = (await getDocumentsDirectory()) + '/bitter';
  } else if (Platform.isMacOS || Platform.isLinux) {
    path = (await getDownloadsDirectory()).path + '/bitter';
  } else if (Platform.isAndroid) {
    path = (await getExternalStorageDirectories(type: StorageDirectory.downloads)).first.path;
  } else {
    path = (await getApplicationDocumentsDirectory()).path + '/bitter';
  }

  if (EnvironmentConfig.debug) {
    return path + '/debug';
  }
  return path;
}

Future<String> getLogPath() async {
  String path;
  if (Platform.isWindows) {
    path = (await getDocumentsDirectory()) + '/bitter/log';
  } else if (Platform.isMacOS) {
    path = (await getDownloadsDirectory()).path + '/bitter/log';
  } else {
    path = (await getApplicationDocumentsDirectory()).path + '/log';
  }

  if (EnvironmentConfig.debug) {
    return path + '/debug';
  }
  return path;
}
