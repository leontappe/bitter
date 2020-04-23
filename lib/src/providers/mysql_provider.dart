import 'package:meta/meta.dart';
import 'package:mysql1/mysql1.dart';

import 'database_provider.dart';

class MySqlProvider extends DatabaseProvider {
  MySqlConnection conn;

  @override
  Future<void> createTable(
      String table, List<String> columns, List<String> types, String primaryKey,
      {List<bool> nullable}) async {
    var cols = '';
    var i = 0;
    for (var item in columns) {
      cols = '$cols$item ${types[i]}';
      if (item == primaryKey) {
        cols = '$cols PRIMARY KEY AUTO_INCREMENT';
      }
      if (nullable != null && !nullable[i]) {
        cols = '$cols NOT NULL';
      }
      cols = '$cols, ';
      i++;
    }
    cols = cols.substring(0, cols.length - 2);
    final query = 'CREATE TABLE IF NOT EXISTS $table($cols);';
    await conn.query(query);
  }

  @override
  Future<int> delete(String table, int id) async {
    return (await conn.query('DELETE FROM $table WHERE id = ?', [id])).affectedRows;
  }

  @override
  Future<void> dropTable(String table) async {
    await conn.query('DROP TABLE $table;');
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> item) async {
    var cols = '';
    for (var col in item.keys) {
      cols += '$col, ';
    }
    cols = cols.substring(0, cols.length - 2);
    var vals = '';
    for (var i = 0; i < item.values.length; i++) {
      vals += '?, ';
    }
    vals = vals.substring(0, vals.length - 2);

    final result =
        await conn.query('INSERT INTO $table ($cols) VALUES ($vals);', item.values.toList());

    return result.insertId;
  }

  @override
  Future<void> open(String database,
      {@required String host, @required int port, String user, String password}) async {
    conn = await MySqlConnection.connect(
        ConnectionSettings(db: database, host: host, port: port, user: user, password: password));
  }

  @override
  Future<List<Map>> select(String table) async {
    return List.from((await conn.query('SELECT * FROM $table;')).map<Map>((Row e) => e.fields));
  }

  @override
  Future<Map> selectSingle(String table, int id) async {
    final result = (await conn.query('SELECT * FROM $table WHERE id = ?;', <dynamic>[id]))
        .map<Map>((Row e) => e.fields);

    if (result.isNotEmpty) {
      return result.single;
    }
    return null;
  }

  @override
  Future<int> update(String table, int id, Map<String, dynamic> item) async {
    final columns = item.keys;
    final values = item.values;
    var cols = '';
    for (var item in columns) {
      cols = '$cols$item=?, ';
    }
    cols = cols.substring(0, cols.length - 2);

    return (await conn.query('UPDATE $table SET $cols WHERE id=?;', <dynamic>[...values, id]))
        .affectedRows;
  }
}
