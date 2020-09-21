import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:mysql1/mysql1.dart';

import '../models/database_error.dart';
import 'database_provider.dart';

class MySqlProvider extends DatabaseProvider {
  MySqlConnection conn;
  StreamController<DatabaseError> _errors;

  MySqlProvider() {
    _errors = StreamController<DatabaseError>.broadcast();
  }

  @override
  Stream<DatabaseError> get errors => _errors.stream;

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

    try {
      await conn.query(query);
    } on SocketException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.create,
          exception: e,
          description: (e.message.contains('Failed host lookup'))
              ? 'Host ${e.address.host} konnte nicht aufgelöst werden'
              : 'Verbindung durch Zeitüberschreitung fehlgeschlagen'));
    } on MySqlException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.create,
          exception: e, description: _mySqlExceptionText(e)));
    }
  }

  @override
  Future<int> delete(String table, int id) async {
    int result;
    try {
      result = (await conn.query('DELETE FROM $table WHERE id = ?', [id])).affectedRows;
    } on SocketException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.delete,
          exception: e, description: _socketExceptionText(e)));
    } on MySqlException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.delete,
          exception: e, description: _mySqlExceptionText(e)));
    }
    return result;
  }

  @override
  Future<void> dropTable(String table) async {
    try {
      await conn.query('DROP TABLE $table;');
    } on SocketException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.drop,
          exception: e, description: _socketExceptionText(e)));
    } on MySqlException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.drop,
          exception: e, description: _mySqlExceptionText(e)));
    }
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

    int result;

    try {
      result =
          (await conn.query('INSERT INTO $table ($cols) VALUES ($vals);', item.values.toList()))
              .insertId;
    } on SocketException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.insert,
          exception: e, description: _socketExceptionText(e)));
    } on MySqlException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.insert,
          exception: e, description: _mySqlExceptionText(e)));
    }

    return result;
  }

  @override
  Future<bool> open(String database,
      {@required String host, @required int port, String user, String password}) async {
    try {
      conn = await MySqlConnection.connect(
          ConnectionSettings(db: database, host: host, port: port, user: user, password: password));
    } on SocketException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.open,
          exception: e, description: _socketExceptionText(e)));
    } on MySqlException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.open,
          exception: e, description: _mySqlExceptionText(e)));
    }
    return conn != null;
  }

  @override
  Future<List<Map>> select(String table) async {
    Results result;
    try {
      result = await conn.query('SELECT * FROM $table;');
    } on SocketException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.select,
          exception: e, description: _socketExceptionText(e)));
    } on MySqlException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.select,
          exception: e, description: _mySqlExceptionText(e)));
    }
    if (result == null) return null;
    return List.from(result.map<Map>((Row e) => e.fields));
  }

  @override
  Future<Map> selectSingle(String table, int id) async {
    Iterable<Map<dynamic, dynamic>> result = [];
    try {
      result = (await conn.query('SELECT * FROM $table WHERE id = ?;', <dynamic>[id]))
          .map<Map>((Row e) => e.fields);
    } on SocketException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.selectSingle,
          exception: e, description: _socketExceptionText(e)));
    } on MySqlException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.selectSingle,
          exception: e, description: _mySqlExceptionText(e)));
    }

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

    int result;

    try {
      result = (await conn.query('UPDATE $table SET $cols WHERE id=?;', <dynamic>[...values, id]))
          .affectedRows;
    } on SocketException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.update,
          exception: e, description: _socketExceptionText(e)));
    } on MySqlException catch (e) {
      _errors.add(DatabaseError(DatabaseErrorCategory.update,
          exception: e, description: _mySqlExceptionText(e)));
    }

    return result;
  }

  String _mySqlExceptionText(MySqlException e) {
    return 'MySQL Fehler: ${e.message}.';
  }

  String _socketExceptionText(SocketException e) {
    return e.message.contains('Failed host lookup')
        ? 'Host konnte nicht aufgelöst werden. Bitte prüfe die Anwendungseinstellungen.'
        : e.message.contains('Socket has been closed')
            ? 'Verbindung wurde vorzeitig geschlossen. Bitte prüfe die Anwendungseinstellungen.'
            : e.message.contains('timed out')
                ? 'Verbindung durch Zeitüberschreitung fehlgeschlagen. Bitte überprüfe deine Internetverbindung und/oder VPN.'
                : (e.osError?.message ?? '').contains('Connection refused')
                    ? 'Verbindung wurde vom Server abgelehnt. Bitte prüfe die Anwendungseinstellungen.'
                    : 'Unbekanntes Verbindungsproblem: ${e}.';
  }
}
