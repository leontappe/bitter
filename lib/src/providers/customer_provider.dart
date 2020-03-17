import 'package:sqflite/sqflite.dart';

import '../models/customer.dart';

export '../models/customer.dart';

const String customerId = 'id';
const String customerName = 'name';
const String customerSurname = 'surname';
const String customerTable = 'customers';

class CustomerProvider {
  Database db;

  void close() async {
    await db.close();
  }

  Future<int> delete(int id) async {
    return await db.delete(customerTable, where: '$customerId = ?', whereArgs: <int>[id]);
  }

  Future<Customer> getCustomer(int id) async {
    List<Map> maps = await db.query(customerTable, where: '$customerId = ?', whereArgs: <int>[id]);
    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Customer>> getCustomers({String searchQuery}) async {
    List<Map> maps;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      maps = await db.query(customerTable);
      var list = maps.map((item) => Customer.fromMap(item));
      return List.from(list.where((Customer c) =>
          (c.name + ' ' + c.surname).toLowerCase().contains(searchQuery.toLowerCase()) ||
          (c.company ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
          (c.organizationUnit ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
          c.email.toLowerCase().contains(searchQuery.toLowerCase())));
    } else {
      maps = await db.query(customerTable);
      return List.from(maps.map<Customer>((item) => Customer.fromMap(item)));
    }
  }

  Future<Customer> insert(Customer customer) async {
    customer.id = await db.insert(customerTable, customer.toMap);
    return customer;
  }

  Future open(String path) async {
    print(await getDatabasesPath() + '/$path');
    db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
create table $customerTable (
  $customerId integer primary key autoincrement,
  company text,
  organization_unit text,
  $customerName text not null,
  $customerSurname text not null,
  gender integer not null,
  address text not null,
  zip_code integer not null,
  city text not null,
  country text,
  telephone text,
  fax text,
  mobile text,
  email text not null
)''');
    });
  }

  Future<int> update(Customer customer) async {
    return await db
        .update(customerTable, customer.toMap, where: '$customerId = ?', whereArgs: <int>[customer.id]);
  }
}
