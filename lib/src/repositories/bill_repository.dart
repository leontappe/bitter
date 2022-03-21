import '../models/bill.dart';
import '../models/item.dart';
import '../providers/database_provider.dart';
import 'settings_repository.dart';

export '../models/bill.dart';

const String tableName = 'bills';

class BillRepository<T extends DatabaseProvider> {
  final T db;

  BillRepository(this.db);

  Future<Bill> insert(Bill bill) async {
    bill.id = await db.insert(tableName, bill.toMap);
    return bill;
  }

  Future<List<Bill>> select({String searchQuery, int vendorFilter, bool short = false}) async {
    var results = (await db.select(tableName, keys: short ? Bill.shortKeys : null))
        .map<Bill>((Map<String, dynamic> e) => Bill.fromMap(e));
    if (searchQuery != null && searchQuery.isNotEmpty) {
      results = results.where((Bill d) => (d.billNr
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          '${d.customer.name} ${d.customer.surname} ${d.customer.company ?? ''} ${d.customer.organizationUnit ?? ''}'
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          '${d.vendor.name} ${d.vendor.contact}'
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          d.items
              .where((Item i) =>
                  '${i.title} ${i.description}'.toLowerCase().contains(searchQuery.toLowerCase()))
              .isNotEmpty));
    }
    if (vendorFilter != null) {
      results =
          results.where((Bill b) => ((vendorFilter != null) ? b.vendor.id == vendorFilter : true));
    }
    return List<Bill>.from(results);
  }

  Future<Bill> selectSingle(int id) async {
    Map<String, dynamic> result;
    try {
      result = await db.selectSingle(tableName, id);
      if (result == null) return null;
      return Bill.fromMap(result);
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
          'status',
          'bill_nr',
          'file',
          'sum',
          'editor',
          'vendor',
          'customer',
          'items',
          'user_message',
          'comment',
          'created',
          'service_date',
          'due_date',
          'note',
          'reminders',
        ],
        [
          'INTEGER',
          'INTEGER',
          'TEXT',
          'LONGTEXT',
          'INTEGER',
          'TEXT',
          'LONGTEXT',
          'TEXT',
          'TEXT',
          'TEXT',
          'TEXT',
          'TEXT',
          'TEXT',
          'TEXT',
          'TEXT',
          'TEXT',
        ],
        'id',
        nullable: <bool>[
          true,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          false,
          true,
          true,
          false,
          false,
          false,
          true,
          true,
        ],
      );
    }
  }

  Future<void> update(Bill bill) async {
    await db.update(tableName, bill.id, bill.toMap);
  }
}
