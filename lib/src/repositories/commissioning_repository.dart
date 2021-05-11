import '../models/commissioning.dart';
import '../providers/database_provider.dart';
import 'settings_repository.dart';

export '../models/commissioning.dart';

const String tableName = 'commissionings';

class CommissioningRepository<T extends DatabaseProvider> {
  final T db;

  CommissioningRepository(this.db);

  Future<void> delete(int id) {
    return db.delete(tableName, id);
  }

  Future<Commissioning> insert(Commissioning commissioning) async {
    commissioning.id = await db.insert(tableName, commissioning.toMap);
    return commissioning;
  }

  Future<List<Commissioning>> select({int vendorFilter, int warehouesFilter}) async {
    var results =
        (await db.select(tableName)).map<Commissioning>((Map e) => Commissioning.fromMap(e));
    if (vendorFilter != null && warehouesFilter == null) {
      results = results.where((Commissioning c) => c.vendorId == vendorFilter);
    }
    if (warehouesFilter != null) {
      results = results.where((Commissioning c) => c.warehouseId == warehouesFilter);
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
    final settings = SettingsRepository();
    await settings.setUp();
    final opened = await db.open(settings.getSqliteName());

    if (opened) {
      await db.createTable(
        tableName,
        ['id', 'vendor_id', 'warehouse_id', 'timestamp', 'items'],
        ['INTEGER', 'INTEGER', 'INTEGER', 'TEXT', 'TEXT'],
        'id',
        nullable: <bool>[true, false, false, false, false],
      );
    }
  }

  Future<void> update(Commissioning commissioning) {
    return db.update(tableName, commissioning.id, commissioning.toMap);
  }
}
