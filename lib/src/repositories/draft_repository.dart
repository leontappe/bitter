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
    var results =
        (await db.select(tableName)).map<Draft>((Map<String, dynamic> e) => Draft.fromMap(e));
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
            (d?.userMessage ?? '').toLowerCase().contains(searchQuery.toLowerCase());
      });
    }
    if (vendorFilter != null) {
      results = results.where((Draft d) => d.vendor == vendorFilter);
    }

    return List<Draft>.from(results);
  }

  Future<Draft> selectSingle(int id) async {
    Map<String, dynamic> result;
    try {
      result = await db.selectSingle(tableName, id);
      if (result == null) return null;
      return Draft.fromMap(result);
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
        [
          'id',
          'editor',
          'customer',
          'vendor',
          'items',
          'tax',
          'service_date',
          'due_days',
          'user_message',
          'comment',
        ],
        [
          'INTEGER',
          'TEXT',
          'INTEGER',
          'INTEGER',
          'TEXT',
          'INTEGER',
          'TEXT',
          'INTEGER',
          'TEXT',
          'TEXT'
        ],
        'id',
        nullable: <bool>[true, false, false, false, false, false, true, false, true, true],
      );
    }
  }

  Future<void> update(Draft draft) {
    return db.update(tableName, draft.id, draft.toMap);
  }
}
