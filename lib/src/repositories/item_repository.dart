import '../models/item.dart';
import '../providers/database_provider.dart';
import 'settings_repository.dart';

export '../models/item.dart';

const String tableName = 'items';

class ItemRepository<T extends DatabaseProvider> {
  final T db;

  ItemRepository(this.db);

  Future<void> delete(int id) {
    return db.delete(tableName, id);
  }

  Future<Item> insert(Item item) async {
    final results = await select(vendorFilter: item.vendor);
    if (results.isEmpty) {
      item.itemId = 1;
    } else {
      item.itemId = results.last.itemId + 1;
    }
    item.id = await db.insert(tableName, item.toMap);
    return item;
  }

  Future<List<Item>> select({String searchQuery, int vendorFilter}) async {
    var results = (await db.select(tableName)).map<Item>((Map e) => Item.fromDbMap(e));
    if (searchQuery != null && searchQuery.isNotEmpty) {
      results = results.where((Item i) {
        return i.title.toLowerCase().contains(searchQuery.toLowerCase());
      });
    }
    if (vendorFilter != null) {
      results = results.where((Item i) => i.vendor == vendorFilter);
    }
    return List<Item>.from(results);
  }

  Future<Item> selectSingle(int id) async {
    return Item.fromMap(await db.selectSingle(tableName, id));
  }

  Future<void> setUp() async {
    final settingsRepo = SettingsRepository();
    await settingsRepo.setUp();
    final settings = await settingsRepo.getMySqlSettings();
    await db.open(
      settings.database,
      host: settings.host,
      port: settings.port,
      user: settings.user,
      password: settings.password,
    );

    await db.createTable(
      tableName,
      ['id', 'title', 'description', 'price', 'tax', 'item_id', 'vendor', 'quantity'],
      ['INTEGER', 'TEXT', 'TEXT', 'INTEGER', 'INTEGER', 'INTEGER', 'INTEGER', 'INTEGER'],
      'id',
      nullable: <bool>[true, false, true, false, false, false, false, false],
    );
  }

  Future<void> update(Item item) {
    return db.update(tableName, item.id, item.toMap);
  }
}
