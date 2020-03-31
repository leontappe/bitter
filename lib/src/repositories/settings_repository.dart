import '../models/mysql_settings.dart';
import '../mysql_credentials.dart';
import '../providers/database_provider.dart';

const String tableName = 'settings';

class SettingsRepository<T extends DatabaseProvider> {
  final T db;

  SettingsRepository(this.db);

  Future<bool> hasMySqlSettings() async => (await db.select(tableName))
      .where((element) => element['setting'] == 'mysql_settings')
      .isNotEmpty;

  Future<int> insertSetting(String key, dynamic value) async {
    return await db.insert(tableName, <String, dynamic>{'setting': key, 'value': value});
  }

  Future<int> setMySqlSettings(MySqlSettings settings) async {
    final _settings =
        (await db.select(tableName)).where((element) => element['setting'] == 'mysql_settings');
    if (_settings.isNotEmpty) {
      return await db.update(tableName, _settings.single['id'] as int, settings.toMap);
    } else {
      return await insertSetting('mysql_settings', settings.toMap.toString());
    }
  }

  Future<void> setUp() async {
    await db.open(
      mySqlSettings.database,
      host: mySqlSettings.host,
      port: mySqlSettings.port,
      user: mySqlSettings.user,
      password: mySqlSettings.password,
    );

    await db.createTable(
      tableName,
      ['id', 'setting', 'value'],
      ['INTEGER', 'TEXT', 'TEXT'],
      'id',
      nullable: <bool>[true, false, false],
    );
  }
}
