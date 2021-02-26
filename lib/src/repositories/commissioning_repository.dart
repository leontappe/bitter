import '../models/commissioning.dart';
import '../providers/database_provider.dart';
import 'settings_repository.dart';

export '../models/commissioning.dart';

const String tableName = 'commissionings';

class WarehouseRepository<T extends DatabaseProvider> {
  final T db;

  WarehouseRepository(this.db);

  Future<void> delete(int id) {
    return db.delete(tableName, id);
  }

  Future<Commissioning> insert(Commissioning commissioning) async {
    commissioning.id = await db.insert(tableName, commissioning.toMap);
    return commissioning;
  }

  Future<List<Commissioning>> select({String searchQuery, int vendorFilter}) async {
    var results =
        (await db.select(tableName)).map<Commissioning>((Map e) => Commissioning.fromMap(e));
    if (vendorFilter != null) {
      results = results.where((Commissioning c) => c.vendorId == vendorFilter);
    }
    return List<Commissioning>.from(results);
  }

  Future<Commissioning> selectSingle(int id) async {
    Map<dynamic, dynamic> result;
    try {
      result = await db.selectSingle(tableName, id);
      if (result == null) return null;
      return Commissioning.fromMap(result);
    } catch (e) {
      return null;
    }
  }

  Future<void> setUp() async {
    final settingsRepo = SettingsRepository();
    await settingsRepo.setUp();
    final settings = await settingsRepo.getMySqlSettings();
    final opened = await db.open(
      settings.database,
      host: settings.host,
      port: settings.port,
      user: settings.user,
      password: settings.password,
    );
    if (opened) {
      await db.createTable(
        tableName,
        ['id', 'vendor_id', 'timestamp', 'items'],
        ['INTEGER', 'INTEGER', 'TEXT', 'TEXT'],
        'id',
        nullable: <bool>[true, false, false, false],
      );
    }
  }

  Future<void> update(Commissioning commissioning) {
    return db.update(tableName, commissioning.id, commissioning.toMap);
  }
}
