import '../models/bill.dart';
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

  Future<List<Bill>> select({String searchQuery}) async {
    final results =
        List<Bill>.from((await db.select(tableName)).map<Bill>((Map e) => Bill.fromMap(e)));
    if (searchQuery != null && searchQuery.isNotEmpty) {
      return List.from(
          results.where((Bill d) => d.billNr.toLowerCase().contains(searchQuery.toLowerCase())));
    } else {
      return results;
    }
  }

  Future<Bill> selectSingle(int id) async {
    return Bill.fromMap(await db.selectSingle(tableName, id));
  }

  Future<void> update(Bill bill) async {
    await db.update(tableName, bill.id, bill.toMap);
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
        'status',
        'bill_nr',
        'file',
        'sum',
        'editor',
        'vendor',
        'customer',
        'items',
        'created',
        'service_date',
        'due_date',
        'note'
      ],
      [
        'INTEGER',
        'INTEGER',
        'TEXT',
        'TEXT',
        'INTEGER',
        'TEXT',
        'TEXT',
        'TEXT',
        'TEXT',
        'DATETIME',
        'DATETIME',
        'DATETIME',
        'TEXT'
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
        false,
        false,
        false,
        true
      ],
    );
  }
}
