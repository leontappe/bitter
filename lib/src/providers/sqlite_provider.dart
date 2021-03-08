import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/database_error.dart';
import '../path_util.dart';
import 'database_provider.dart';

class SqliteProvider extends DatabaseProvider {
  final Logger _log = Logger('SqliteProvider');

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
    _log.fine('creating table named "$table" with $cols');
    final query = 'CREATE TABLE IF NOT EXISTS $table($cols);';
    await conn.execute(query);
  }

  @override
  Future<int> delete(String table, int id) {
    _log.fine('deleting from "$table": $id');
    return conn.delete(table, where: 'id=?', whereArgs: <dynamic>[id]);
  }

  @override
  Future<void> dropTable(String table) {
    _log.fine('dropping "$table"');
    return conn.execute('DROP TABLE $table;');
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> item) {
    _log.fine('inserting into "$table": $item');
    return conn.insert(table, item);
  }

  @override
  Future<bool> open(String path, {String host, int port, String user, String password}) async {
    final dbPath = '${await getConfigPath()}/bitter.db';

    _log.fine('opening DB at $dbPath');

    if (Platform.isLinux || Platform.isWindows) {
      _log.finer('using FFI for windows and linux');
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      conn = await databaseFactory.openDatabase(dbPath);
    } else {
      conn = await openDatabase(dbPath);
    }
    return conn != null && conn.isOpen;
  }

  @override
  Future<List<Map<String, dynamic>>> select(String table, {List<String> keys}) {
    _log.fine('selecting all from "$table"');
    return conn.query(table, columns: keys);
  }

  @override
  Future<Map> selectSingle(String table, int id) async {
    _log.fine('selecting item with id=$id from "$table"');
    return (await conn.query(table, where: 'id=?', whereArgs: <dynamic>[id])).single;
  }

  @override
  Future<int> update(String table, int id, Map<String, dynamic> item) {
    _log.fine('updating $item with id=$id in "$table"');
    return conn.update(table, item, where: 'id=?', whereArgs: <dynamic>[id]);
  }
}
