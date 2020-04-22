import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_provider.dart';

class SqliteProvider extends DatabaseProvider {
  Database conn;

  @override
  Future<void> createTable(
      String table, List<String> columns, List<String> types, String primaryKey,
      {List<bool> nullable}) async {
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
    return conn.execute('DROP TABLE ?;', <dynamic>[table]);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> item) {
    return conn.insert(table, item);
  }

  @override
  Future<void> open(String path, {String host, int port, String user, String password}) async {
    final dbPath = (await getApplicationDocumentsDirectory()).path + '/bitter/bitter.db';

    if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      conn = await databaseFactoryFfi.openDatabase(dbPath);
    } else {
      conn = await openDatabase(dbPath);
    }
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
