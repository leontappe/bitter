import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart';

import '../models/customer.dart';
import 'base_provider.dart';

export '../models/customer.dart';

const String tableName = 'customers';

class PgSQLCustomerProvider implements BaseProvider<Customer> {
  PostgreSQLConnection conn;

  @override
  Future<int> delete(int id) async {
    return await conn.execute('DELETE FROM $tableName WHERE id = @id',
        substitutionValues: <String, dynamic>{'id': id});
  }

  @override
  Future<Customer> insert(Customer customer) async {
    final result = await conn.execute(
      'INSERT INTO $tableName (${customer.company != null ? 'company,' : ''}${customer.organizationUnit != null ? 'organization_unit,' : ''}name, surname, gender, address, zip_code, city, ${customer.country != null ? 'country,' : ''}${customer.telephone != null ? 'telephone,' : ''}${customer.fax != null ? 'fax,' : ''}${customer.mobile != null ? 'mobile,' : ''}email) VALUES (${customer.company != null ? '@company,' : ''}${customer.organizationUnit != null ? '@organization_unit,' : ''}@name, @surname, @gender, @address, @zip_code, @city, ${customer.country != null ? '@country,' : ''}${customer.telephone != null ? '@telephone,' : ''}${customer.fax != null ? '@fax,' : ''}${customer.mobile != null ? '@mobile,' : ''}@email)',
      substitutionValues: customer.toShortMap,
    );
    if (result == 1) {
      return Customer.fromMap(
        (await conn.mappedResultsQuery('SELECT * FROM $tableName ORDER BY id DESC LIMIT 1')).single,
      );
    }
    return null;
  }

  @override
  Future<void> open(String database,
      {@required String host, @required int port, String user, String password}) async {
    conn = PostgreSQLConnection(
      host,
      port,
      database,
      username: user,
      password: password,
    );
    await conn.open();

    /*await conn.query(
        'CREATE TABLE IF NOT EXISTS customers(id SERIAL PRIMARY KEY, company TEXT, organization_unit TEXT, name TEXT NOT NULL, surname TEXT NOT NULL, gender INTEGER NOT NULL, address TEXT NOT NULL, zip_code INTEGER NOT NULL, city TEXT NOT NULL, country TEXT, telephone TEXT, fax TEXT, mobile TEXT, email TEXT NOT NULL);');*/
  }

  @override
  Future<List<Customer>> select({String searchQuery}) async {
    List<Map> maps;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      maps = await conn.mappedResultsQuery('SELECT * FROM $tableName');
      final list = maps.map((Map item) => Customer.fromMap(item));
      return List.from(list.where(
        (Customer c) =>
            (c.name + ' ' + c.surname).toLowerCase().contains(searchQuery.toLowerCase()) ||
            (c.company ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            (c.organizationUnit ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
            c.email.toLowerCase().contains(searchQuery.toLowerCase()),
      ));
    } else {
      maps = await conn.mappedResultsQuery('SELECT * FROM $tableName');
      return List.from(
          maps.map<Customer>((Map item) => Customer.fromMap(item['customers'] as Map)));
    }
  }

  @override
  Future<Customer> selectSingle(int id) async {
    return Customer.fromMap((await conn.mappedResultsQuery(
            'SELECT * FROM $tableName WHERE id = @id',
            substitutionValues: <String, dynamic>{'id': id}))
        .single['customers']);
  }

  @override
  Future<int> update(Customer customer) async {
    return await conn.execute(
      'UPDATE $tableName SET company = @company, organization_unit = @organization_unit, name = @name, surname = @surname, gender = @gender, address = @address, zip_code = @zip_code, city = @city, country = @country, telephone = @telephone, fax = @fax, mobile = @mobile, email = @email WHERE id = @id',
      substitutionValues: <String, dynamic>{...customer.toMap, 'id': customer.id},
    );
  }
}
