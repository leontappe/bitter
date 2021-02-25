import '../models/warehouse.dart';
import '../providers/database_provider.dart';
import 'settings_repository.dart';

export '../models/warehouse.dart';

const String tableName = 'warehouses';

class WarehouseRepository<T extends DatabaseProvider> {
  final T db;

  WarehouseRepository(this.db);

  Future<void> delete(int id) {
    return db.delete(tableName, id);
  }

  Future<Warehouse> insert(Warehouse warehouse) async {
    warehouse.id = await db.insert(tableName, warehouse.toMap);
    return warehouse;
  }

  Future<List<Warehouse>> select({String searchQuery, int vendorFilter}) async {
    var results = (await db.select(tableName)).map<Warehouse>((Map e) => Warehouse.fromMap(e));
    if (searchQuery != null && searchQuery.isNotEmpty) {
      results = results.where((Warehouse w) {
        return w.name.toLowerCase().contains(searchQuery.toLowerCase());
      });
    }
    if (vendorFilter != null) {
      results = results.where((Warehouse w) => w.vendorId == vendorFilter);
    }
    return List<Warehouse>.from(results);
  }

  Future<Warehouse> selectSingle(int id) async {
    Map<dynamic, dynamic> result;
    try {
      result = await db.selectSingle(tableName, id);
      if (result == null) return null;
      return Warehouse.fromMap(result);
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
        ['id', 'name', 'vendor_id', 'inventory'],
        ['INTEGER', 'TEXT', 'INTEGER', 'TEXT'],
        'id',
        nullable: <bool>[true, false, false, true],
      );
    }
  }

  Future<void> update(Warehouse warehouse) {
    return db.update(tableName, warehouse.id, warehouse.toMap);
  }
}
