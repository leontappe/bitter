import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/database_error.dart';
import '../util.dart';
import 'database_provider.dart';

class SqliteProvider extends DatabaseProvider {
  Database conn;
  StreamController<DatabaseError> _errors;

  SqliteProvider() {
    _errors = StreamController<DatabaseError>.broadcast();
  }

  @override
  Stream<DatabaseError> get errors => _errors.stream;

  @override
  Future<void> createTable(
      String table, List<String> columns, List<String> types, String primaryKey,
      {List<bool> nullable}) async {
    // replace LONGTEXT with TEXT for SqLite
    for (var i = 0; i < types.length; i++) {
      if (types[i] == 'LONGTEXT') {
        types[i] = 'TEXT';
      }
    }

    var cols = '';
    var i = 0;
    for (var item in columns) {
      cols = '$cols$item ${types[i]}';
      if (item == primaryKey) {
        cols = '$cols PRIMARY KEY AUTOINCREMENT';
      }
      if (nullable != null && !nullable[i]) {
        cols = '$cols NOT NULL';
      }
      cols = '$cols, ';
      i++;
    }
    cols = cols.substring(0, cols.length - 2);
    final query = 'CREATE TABLE IF NOT EXISTS $table($cols);';
    await conn.execute(query);
  }

  @override
  Future<int> delete(String table, int id) {
    return conn.delete(table, where: 'id=?', whereArgs: <dynamic>[id]);
  }

  @override
  Future<void> dropTable(String table) {
    return conn.execute('DROP TABLE $table;');
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> item) {
    return conn.insert(table, item);
  }

  @override
  Future<bool> open(String path, {String host, int port, String user, String password}) async {
    final dbPath = '${await getConfigPath()}/bitter.db';

    if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      conn = await databaseFactory.openDatabase(dbPath);
    } else {
      conn = await openDatabase(dbPath);
    }
    return conn != null && conn.isOpen;
  }

  @override
  Future<List<Map<String, dynamic>>> select(String table) {
    return conn.query(table);
  }

  @override
  Future<Map> selectSingle(String table, int id) async {
    return (await conn.query(table, where: 'id=?', whereArgs: <dynamic>[id])).single;
  }

  @override
  Future<int> update(String table, int id, Map<String, dynamic> item) {
    return conn.update(table, item, where: 'id=?', whereArgs: <dynamic>[id]);
  }
}
