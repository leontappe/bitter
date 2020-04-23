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
    item.id = await db.insert(tableName, item.toMap);
    return item;
  }

  Future<List<Item>> select({String searchQuery}) async {
    var results = (await db.select(tableName)).map<Item>((Map e) => Item.fromMap(e));
    if (searchQuery != null && searchQuery.isNotEmpty) {
      results = results.where((Item i) {
        return i.title.toString().contains(searchQuery);
      });
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
      ['id', 'title', 'description', 'price', 'tax'],
      ['INTEGER', 'TEXT', 'TEXT', 'INTEGER', 'INTEGER'],
      'id',
      nullable: <bool>[true, false, true, false, false],
    );
  }

  Future<void> update(Item item) {
    return db.update(tableName, item.id, item.toMap);
  }
}
