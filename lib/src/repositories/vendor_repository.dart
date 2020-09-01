import '../models/vendor.dart';
import '../providers/database_provider.dart';
import 'settings_repository.dart';

export '../models/vendor.dart';

const String tableName = 'vendors';

class VendorRepository<T extends DatabaseProvider> {
  final T db;

  VendorRepository(this.db);

  Future<void> delete(int id) {
    return db.delete(tableName, id);
  }

  Future<Vendor> insert(Vendor vendor) async {
    vendor.id = await db.insert(tableName, vendor.toMap);
    return vendor;
  }

  Future<List<Vendor>> select({String searchQuery}) async {
    final results =
        List<Vendor>.from((await db.select(tableName)).map<Vendor>((Map e) => Vendor.fromMap(e)));

    if (searchQuery != null && searchQuery.isNotEmpty) {
      return List.from(
          results.where((Vendor v) => (v.name).toLowerCase().contains(searchQuery.toLowerCase())));
    } else {
      return results;
    }
  }

  Future<Vendor> selectSingle(int id) async {
    return Vendor.fromMap(await db.selectSingle(tableName, id));
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
        'name',
        'manager',
        'contact',
        'address',
        'zip_code',
        'city',
        'iban',
        'bic',
        'bank',
        'tax_nr',
        'vat_nr',
        'email',
        'website',
        'full_address',
        'bill_prefix',
        'default_due_days',
        'default_tax',
        'default_comment',
        'header_image_right',
        'header_image_center',
        'header_image_left',
        'user_message_label',
      ],
      [
        'INTEGER',
        'TEXT',
        'TEXT',
        'TEXT',
        'TEXT',
        'INTEGER',
        'TEXT',
        'TEXT',
        'TEXT',
        'TEXT',
        'TEXT',
        'TEXT',
        'TEXT',
        'TEXT',
        'TEXT',
        'TEXT',
        'INTEGER',
        'INTEGER',
        'TEXT',
        'LONGTEXT',
        'LONGTEXT',
        'LONGTEXT',
        'TEXT',
      ],
      'id',
      nullable: <bool>[
        true,
        false,
        true,
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
        true,
        false,
        false,
        true,
        true,
        true,
        true,
        true,
        true,
        true,
      ],
    );
  }

  Future<void> update(Vendor vendor) {
    return db.update(tableName, vendor.id, vendor.toMap);
  }
}
