import '../models/customer.dart';
import '../providers/database_provider.dart';
import 'settings_repository.dart';

export '../models/customer.dart';

const String tableName = 'customers';

class CustomerRepository<T extends DatabaseProvider> {
  final T db;

  CustomerRepository(this.db);

  Future<void> delete(int id) {
    return db.delete(tableName, id);
  }

  Future<Customer> insert(Customer customer) async {
    customer.id = await db.insert(tableName, customer.toMap);
    return customer;
  }

  Future<List<Customer>> select({String searchQuery}) async {
    final results = List<Customer>.from(
        (await db.select(tableName)).map<Customer>((Map e) => Customer.fromMap(e)));

    if (searchQuery != null && searchQuery.isNotEmpty) {
      return List.from(results.where((Customer c) =>
          (c.name + ' ' + c.surname).toLowerCase().contains(searchQuery.toLowerCase()) ||
          (c.company ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
          (c.organizationUnit ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
          c.email.toLowerCase().contains(searchQuery.toLowerCase())));
    } else {
      return results;
    }
  }

  Future<Customer> selectSingle(int id) async {
    Map<dynamic, dynamic> result;
    try {
      result = await db.selectSingle(tableName, id);
      if (result == null) return null;
      return Customer.fromMap(result);
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
        [
          'id',
          'company',
          'organization_unit',
          'name',
          'surname',
          'gender',
          'address',
          'zip_code',
          'city',
          'country',
          'telephone',
          'fax',
          'mobile',
          'email'
        ],
        [
          'INTEGER',
          'TEXT',
          'TEXT',
          'TEXT',
          'TEXT',
          'INTEGER',
          'TEXT',
          'INTEGER',
          'TEXT',
          'TEXT',
          'TEXT',
          'TEXT',
          'TEXT',
          'TEXT'
        ],
        'id',
        nullable: <bool>[
          true,
          true,
          true,
          false,
          false,
          false,
          false,
          false,
          false,
          true,
          true,
          true,
          true,
          false
        ],
      );
    }
  }

  Future<void> update(Customer customer) {
    return db.update(tableName, customer.id, customer.toMap);
  }
}
