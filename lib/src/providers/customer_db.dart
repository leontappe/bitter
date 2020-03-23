import 'package:database/database.dart';
import 'package:database/database_adapter.dart';
import 'package:database/sql.dart';
import 'package:database_adapter_sqlite/database_adapter_sqlite.dart';

import '../models/customer.dart';
import 'base_provider.dart';

export '../models/customer.dart';

const String tableName = 'customers';

class CustomerProvider implements BaseProvider<Customer> {
  Database db;
  SqlClient client;

  @override
  Future<int> delete(int id) async {
    await client.table(tableName).dropIndex(id.toString());
    return id;
  }

  @override
  Future<Customer> insert(Customer customer) async {
    final result = await client.table(tableName).insert(customer.toMap);
    if (result.affectedRows == 1) {
      return Customer.fromMap(
        (await client.table(tableName).descending('id').limit(1).select().toMaps()).single,
      );
    }
    return null;
  }

  @override
  Future<void> open(String path, {DatabaseAdapter adapter}) async {
    if (adapter == null) {
      db = SQLite(path: path).database();
    } else {
      db = adapter.database();
    }
    client = db.sqlClient;
    await client.rawQuery(SqlStatement(
        'CREATE TABLE IF NOT EXISTS $tableName(id integer primary key autoincrement, company text, organization_unit text, name text not null, surname text not null, gender integer not null, address text not null, zip_code integer not null, city text not null, country text, telephone text, fax text, mobile text, email text not null);'));
  }

  @override
  Future<List<Customer>> select({String searchQuery}) async {
    List<Map> maps;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      maps = await client.table(tableName).select().toMaps();
      var list = maps.map((Map item) => Customer.fromMap(item));
      return List.from(list.where(
        (Customer c) =>
            (c.name + ' ' + c.surname).toLowerCase().contains(searchQuery.toLowerCase()) ||
            (c.company ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            (c.organizationUnit ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            c.email.toLowerCase().contains(searchQuery.toLowerCase()),
      ));
    } else {
      maps = await client.table(tableName).select().toMaps();
      return List.from(maps.map<Customer>((item) => Customer.fromMap(item)));
    }
  }

  @override
  Future<Customer> selectSingle(int id) async {
    return Customer.fromMap(
        (await client.table(tableName).whereColumn('id', equals: id).select().toMaps()).single);
  }

  @override
  Future<int> update(Customer customer) async {
    final result = await client.execute(
      'UPDATE $tableName SET company = ?, organization_unit = ?, name = ?, surname = ?, gender = ?, address = ?, zip_code = ?, city = ?, country = ?, telephone = ?, fax = ?, mobile = ?, email = ? WHERE id = ?',
      <dynamic>[
        customer.company,
        customer.organizationUnit,
        customer.name,
        customer.surname,
        customer.gender.index,
        customer.address,
        customer.zipCode,
        customer.city,
        customer.country,
        customer.telephone,
        customer.fax,
        customer.mobile,
        customer.email,
        customer.id,
      ],
    );
    return result.affectedRows;
  }
}
