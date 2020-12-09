import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import '../models/mysql_settings.dart';
import '../util.dart';

export '../models/mysql_settings.dart';

const dbKey = 'db_engine';
const mySqlKey = 'mysql_settings';
const userKey = 'username';

enum DbEngine {
  mysql,
  sqlite,
}

class SettingsRepository {
  final Logger _log = Logger('SettingsRepository');

  String basePath;
  String dataPath;

  File data;

  SettingsRepository();

  Map get _getCurrentSettings => (json.decode(data.readAsStringSync())) as Map;

  DbEngine getDbEngine() {
    final setting = select<int>(dbKey);
    return _intToDb(setting);
  }

  MySqlSettings getMySqlSettings() {
    final settings = select<Map>(mySqlKey);
    if (settings != null) {
      return MySqlSettings.fromMap(settings);
    } else {
      return MySqlSettings.standard();
    }
  }

  String getUsername() => select<String>(userKey);

  bool hasDbEngine() => _hasGeneric(dbKey);

  bool hasMySqlSettings() => _hasGeneric(userKey);

  bool hasUsername() => _hasGeneric(userKey);

  Future<void> insert(String key, dynamic value) async {
    _log.config('inserting $key:$value');
    final settings = await _getCurrentSettings;
    settings.addEntries(<MapEntry<String, dynamic>>[MapEntry<String, dynamic>(key, value)]);
    _log.fine('content of new config: $settings');
    await _writeSettings(settings);
  }

  T select<T>(String key) {
    _log.fine('selecting $key of type $T');
    if (_hasGeneric(key)) {
      _log.fine('found $key:${_getCurrentSettings[key]}');
      return _getCurrentSettings[key] as T;
    } else {
      return null;
    }
  }

  Future<void> setDbEngine(DbEngine engine) => insert(dbKey, engine.index);

  Future<void> setMySqlSettings(MySqlSettings settings) => insert(mySqlKey, settings.toMap);

  Future<void> setUp() async {
    data = File((await getConfigPath()) + '/settings.json');
    _log.fine('setting up configuration in ${data.path}');
    await data.create(recursive: true);

    final oldData = await data.readAsString();
    _log.fine('content of existing config: $oldData');
    if (oldData.isEmpty) {
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
        return null;
    }
  } //&& ((await select(key)).toString().isNotEmpty);

  Future<void> _writeSettings(Map map) async =>
      await data.writeAsBytes(utf8.encode(json.encode(map)));
}
