import '../models/customer.dart';
import '../models/draft.dart';
import '../models/item.dart';
import '../models/vendor.dart';
import '../providers/database_provider.dart';
import 'settings_repository.dart';

export '../models/draft.dart';

const String tableName = 'drafts';

class DraftRepository<T extends DatabaseProvider> {
  final T db;

  DraftRepository(this.db);

  Future<void> delete(int id) {
    return db.delete(tableName, id);
  }

  Future<Draft> insert(Draft draft) async {
    draft.id = await db.insert(tableName, draft.toMap);
    return draft;
  }

  Future<List<Draft>> select({
    String searchQuery,
    int vendorFilter,
    List<Customer> customers = const [],
    List<Vendor> vendors = const [],
  }) async {
    var results = (await db.select(tableName)).map<Draft>((Map e) => Draft.fromMap(e));
    if (searchQuery != null && searchQuery.isNotEmpty) {
      results = results.where((Draft d) {
        final customer = (customers.where((Customer c) => c.id == d.customer).isNotEmpty)
            ? customers.singleWhere((Customer c) => c.id == d.customer)
            : null;
        final vendor = (vendors.where((Vendor v) => v.id == d.vendor).isNotEmpty)
            ? vendors.singleWhere((Vendor v) => v.id == d.vendor)
            : null;

        return d.id.toString().contains(searchQuery) ||
            d.editor.toLowerCase().contains(searchQuery.toLowerCase()) ||
            d.items
                .where((Item i) => i.title.toLowerCase().contains(searchQuery.toLowerCase()))
                .isNotEmpty ||
            d.items
                .where((Item i) =>
                    (i.description ?? '').toLowerCase().contains(searchQuery.toLowerCase()))
                .isNotEmpty ||
            (customer?.company ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            (customer?.organizationUnit ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            (customer?.name ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            (customer?.surname ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            (vendor?.name ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            d.userMessage.toLowerCase().contains(searchQuery.toLowerCase());
      });
    }
    if (vendorFilter != null) {
      results = results.where((Draft d) => d.vendor == vendorFilter);
    }

    return List<Draft>.from(results);
  }

  Future<Draft> selectSingle(int id) async {
    return Draft.fromMap(await db.selectSingle(tableName, id));
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
      [
        'id',
        'editor',
        'customer',
        'vendor',
        'items',
        'tax',
        'service_date',
        'due_days',
        'user_message'
      ],
      ['INTEGER', 'TEXT', 'INTEGER', 'INTEGER', 'TEXT', 'INTEGER', 'DATETIME', 'INTEGER', 'TEXT'],
      'id',
      nullable: <bool>[true, false, false, false, false, false, true, false, true],
    );
  }

  Future<void> update(Draft draft) {
    return db.update(tableName, draft.id, draft.toMap);
  }
}
