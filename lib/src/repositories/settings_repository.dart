import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/mysql_settings.dart';

export '../models/mysql_settings.dart';

const dbKey = 'db_engine';
const mySqlKey = 'mysql_settings';
const userKey = 'username';

enum DbEngine {
  mysql,
  sqlite,
}

class SettingsRepository {
  String basePath;
  String dataPath;

  File data;

  SettingsRepository();

  Map get _getCurrentSettings => (json.decode(data.readAsStringSync())) as Map;

  DbEngine getDbEngine() {
    final setting = select(dbKey) as int;
    return _intToDb(setting);
  }

  Future<MySqlSettings> getMySqlSettings() async {
    final settings = await select(mySqlKey) as Map;
    if (settings != null) {
      return MySqlSettings.fromMap(settings);
    } else {
      return MySqlSettings.standard();
    }
  }

  Future<String> getUsername() async => (await select(userKey)) as String;

  bool hasDbEngine() => _hasGeneric(dbKey);

  bool hasMySqlSettings() => _hasGeneric(userKey);

  bool hasUsername() => _hasGeneric(userKey);

  Future<void> insert(String key, dynamic value) async {
    final settings = await _getCurrentSettings;
    settings.addEntries(<MapEntry<String, dynamic>>[MapEntry<String, dynamic>(key, value)]);
    await _writeSettings(settings);
  }

  dynamic select(String key) {
    if (_hasGeneric(key)) {
      return _getCurrentSettings[key];
    } else {
      return null;
    }
  }

  Future<void> setDbEngine(DbEngine engine) => insert(dbKey, engine.index);

  Future<void> setMySqlSettings(MySqlSettings settings) => insert(mySqlKey, settings.toMap);

  Future<void> setUp() async {
    basePath = (await getApplicationDocumentsDirectory()).path;
    //print(basePath);
    if (Platform.isWindows) {
      dataPath = basePath + '/bitter/config/settings.json';
    } else if (Platform.isLinux) {
      dataPath = basePath + 'bitter/settings.json';
    } else {
      dataPath = basePath + '/settings.json';
    }
    data = File(dataPath);
    await data.create(recursive: true);

    if ((await data.readAsString()).isEmpty) {
      await _writeSettings(<String, String>{});
    }
  }

  Future<void> setUsername(String username) => insert(userKey, username);

  bool _hasGeneric(String key) => _getCurrentSettings.containsKey(key);

  DbEngine _intToDb(int index) {
    switch (index) {
      case 0:
        return DbEngine.mysql;
      case 1:
        return DbEngine.sqlite;
      default:
        return DbEngine.sqlite;
    }
  } //&& ((await select(key)).toString().isNotEmpty);

  Future<void> _writeSettings(Map map) async =>
      await data.writeAsBytes(utf8.encode(json.encode(map)));
}
