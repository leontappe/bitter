import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/mysql_settings.dart';

export '../models/mysql_settings.dart';

class SettingsRepository {
  String basePath;
  String dataPath;

  File data;

  SettingsRepository();

  Future<Map> get _getCurrentSettings async => (json.decode(data.readAsStringSync())) as Map;

  Future<MySqlSettings> getMySqlSettings() async {
    return MySqlSettings.fromMap(await select('mysql_settings') as Map);
  }

  Future<String> getUsername() async => (await select('username')) as String;

  Future<bool> hasMySqlSettings() => _hasGeneric('username');

  Future<bool> hasUsername() => _hasGeneric('username');

  Future<void> insert(String key, dynamic value) async {
    final settings = await _getCurrentSettings;
    settings.addEntries(<MapEntry<String, dynamic>>[MapEntry<String, dynamic>(key, value)]);
    await _writeSettings(settings);
  }

  Future<dynamic> select(String key) async {
    if (await _hasGeneric(key)) {
      return (await _getCurrentSettings)[key];
    } else {
      return null;
    }
  }

  Future<void> setMySqlSettings(MySqlSettings settings) async {
    await insert('mysql_settings', settings.toMap);
  }

  Future<void> setUp() async {
    basePath = (await getApplicationDocumentsDirectory()).path;
    if (Platform.isWindows) {
      dataPath = basePath + '/bitter/config/settings.json';
    } else {
      dataPath = basePath + '/settings.json';
    }
    data = File(dataPath);
    await data.create(recursive: true);

    if ((await data.readAsString()).isEmpty) {
      await _writeSettings(<String, String>{});
    }
  }

  Future<void> setUsername(String username) async => await insert('username', username);

  Future<bool> _hasGeneric(String key) async =>
      ((await _getCurrentSettings).containsKey(key)); //&& ((await select(key)).toString().isNotEmpty);

  Future<void> _writeSettings(Map map) async =>
      await data.writeAsBytes(utf8.encode(json.encode(map)));
}
