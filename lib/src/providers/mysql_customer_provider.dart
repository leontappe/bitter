import 'package:meta/meta.dart';
import 'package:mysql1/mysql1.dart';

import '../models/customer.dart';
import '../providers/base_provider.dart';

export '../models/customer.dart';

const String tableName = 'customers';

class MySQLCustomerProvider extends BaseProvider<Customer> {
  MySqlConnection conn;

  @override
  Future<int> delete(int id) async {
    return (await conn.query('DELETE FROM $tableName WHERE id = ?', <dynamic>[id])).affectedRows;
  }

  @override
  Future<Customer> insert(Customer customer) async {
    final result = await conn.query(
      'INSERT INTO $tableName (${customer.company != null ? 'company,' : ''}${customer.organizationUnit != null ? 'organization_unit,' : ''}name, surname, gender, address, zip_code, city, ${customer.country != null ? 'country,' : ''}${customer.telephone != null ? 'telephone,' : ''}${customer.fax != null ? 'fax,' : ''}${customer.mobile != null ? 'mobile,' : ''}email) VALUES (${customer.company != null ? '?,' : ''}${customer.organizationUnit != null ? '?,' : ''}?, ?, ?, ?, ?, ?, ${customer.country != null ? '?,' : ''}${customer.telephone != null ? '?,' : ''}${customer.fax != null ? '?,' : ''}${customer.mobile != null ? '?,' : ''}?)',
      customer.toShortMap.values.toList(),
    );
    if (result.isNotEmpty) {
      return Customer.fromMap(
        (await conn.query('SELECT * FROM $tableName ORDER BY id DESC LIMIT 1')).single.fields,
      );
    }
    return null;
  }

  @override
  Future<void> open(String database,
      {@required String host, @required int port, String user, String password}) async {
    conn = await MySqlConnection.connect(
        ConnectionSettings(db: database, host: host, port: port, user: user, password: password));
    await conn.query(
        'CREATE TABLE IF NOT EXISTS customers(id INTEGER PRIMARY KEY AUTO_INCREMENT, company TEXT, organization_unit TEXT, name TEXT NOT NULL, surname TEXT NOT NULL, gender INTEGER NOT NULL, address TEXT NOT NULL, zip_code INTEGER NOT NULL, city TEXT NOT NULL, country TEXT, telephone TEXT, fax TEXT, mobile TEXT, email TEXT NOT NULL);');
  }

  @override
  Future<List<Customer>> select({String searchQuery}) async {
    List<Map> maps;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      maps =
          List.from((await conn.query('SELECT * FROM $tableName')).map<Map>((Row e) => e.fields));
      final list = maps.map((Map item) => Customer.fromMap(item));
      return List.from(list.where(
        (Customer c) =>
            (c.name + ' ' + c.surname).toLowerCase().contains(searchQuery.toLowerCase()) ||
            (c.company ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            (c.organizationUnit ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            c.email.toLowerCase().contains(searchQuery.toLowerCase()),
      ));
    } else {
      maps =
          List.from((await conn.query('SELECT * FROM $tableName')).map<Map>((Row e) => e.fields));
      return List.from(maps.map<Customer>((Map item) => Customer.fromMap(item)));
    }
  }

  @override
  Future<Customer> selectSingle(int id) async {
    return Customer.fromMap(
        (await conn.query('SELECT * FROM $tableName WHERE id = ?', <dynamic>[id]))
            .map<Map>((Row e) => e.fields)
            .single);
  }

  @override
  Future<int> update(Customer customer) async {
    return (await conn.query(
      'UPDATE $tableName SET company = ?, organization_unit = ?, name = ?, surname = ?, gender = ?, address = ?, zip_code = ?, city = ?, country = ?, telephone = ?, fax = ?, mobile = ?, email = ? WHERE id = ?',
      <dynamic>[...customer.toMap.values.toList(), customer.id],
    ))
        .affectedRows;
  }
}
