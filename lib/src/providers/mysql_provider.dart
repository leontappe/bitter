import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:mysql1/mysql1.dart';
import 'package:uuid/uuid.dart';

import '../models/database_error.dart';
import 'database_provider.dart';

class MySqlProvider extends DatabaseProvider with PooledDatabaseProvider {
  final Logger _log = Logger('MySqlProvider');

  StreamController<DatabaseError> _errors;

  List<PooledConnection> connections;
  StreamController<Query> _queries;
  StreamController<PooledResult> _results;

  StreamSubscription<Query> _listener;

  MySqlProvider() {
    _errors = StreamController<DatabaseError>.broadcast();
    _results = StreamController<PooledResult>.broadcast();
    _queries = StreamController<Query>();
  }

  @override
  Stream<DatabaseError> get errors => _errors.stream;

  @override
  Future<void> close() async {
    await _listener.cancel();
    for (var connection in connections) {
      await connection.connection.close();
    }
    await _queries.close();
    await _results.close();
    await _errors.close();
  }

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

    _log.fine('creating table named "$table" with $cols');

    final poolQuery = Query(query);
    _queries.add(poolQuery);

    return (await _results.stream.firstWhere((PooledResult result) => result.uid == poolQuery.uid));
  }

  @override
  Future<int> delete(String table, int id) async {
    _log.fine('deleting from "$table": $id');
    final poolQuery = Query('DELETE FROM $table WHERE id = ?', <dynamic>[id]);
    _queries.add(poolQuery);
    return (await _results.stream.firstWhere((PooledResult result) => result.uid == poolQuery.uid))
        .results
        .affectedRows;
  }

  @override
  Future<void> dropTable(String table) async {
    _log.fine('dropping "$table"');
    final poolQuery = Query('DROP TABLE $table;');
    _queries.add(poolQuery);
    return (await _results.stream.firstWhere((PooledResult result) => result.uid == poolQuery.uid));
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> item) async {
    _log.fine('inserting into "$table": $item');
    var cols = '';
    for (var col in item.keys) {
      cols += '$col, ';
    }
    cols = cols.substring(0, cols.length - 2);
    var values = '';
    for (var i = 0; i < item.values.length; i++) {
      values += '?, ';
    }
    values = values.substring(0, values.length - 2);

    final poolQuery = Query('INSERT INTO $table ($cols) VALUES ($values);', item.values.toList());
    _queries.add(poolQuery);

    return (await _results.stream.firstWhere((PooledResult result) => result.uid == poolQuery.uid))
        .results
        .insertId;
  }

  @override
  Future<bool> open(String path, {String host, int port, String user, String password}) {
    return Future.value(connections.isNotEmpty);
  }

  @override
  Future<bool> openPool(
    String path, {
    @required String host,
    @required int port,
    String user,
    String password,
    int size = 10,
  }) async {
    _log.fine('opening DB on sql://$user:password@$host:$port');
    connections = <PooledConnection>[];
    for (var i = 0; i < size; i++) {
      _log.fine('spawning connection ${i + 1}');
      try {
        connections.add(PooledConnection(await MySqlConnection.connect(
            ConnectionSettings(db: path, host: host, port: port, user: user, password: password))));
      } on SocketException catch (e) {
        _log.severe('$e ${_socketExceptionText(e)}');
        _errors.add(DatabaseError(DatabaseErrorCategory.open,
            exception: e, description: _socketExceptionText(e)));
      } on MySqlException catch (e) {
        _log.severe('$e ${_mySqlExceptionText(e)}');
        _errors.add(DatabaseError(DatabaseErrorCategory.open,
            exception: e, description: _mySqlExceptionText(e)));
      }
    }

    var connsString = connections.join(' \n');
    _log.info('available connections:\n$connsString');

    if (connections.length != size) return false;

    _listener = _queries.stream.listen((Query q) async {
      final freeConn = connections.firstWhere((PooledConnection conn) => !conn.busy);
      _log.fine('starting query "${q.query}" on $freeConn');
      freeConn.busy = true;
      try {
        _results.add(PooledResult(q.uid, await freeConn.connection.query(q.query, q.values)));
      } on SocketException catch (e) {
        _log.severe('$e ${_socketExceptionText(e)}');
        _errors.add(DatabaseError(DatabaseErrorCategory.create,
            exception: e,
            description: (e.message.contains('Failed host lookup'))
                ? 'Host ${e.address.host} konnte nicht aufgelöst werden'
                : 'Verbindung durch Zeitüberschreitung fehlgeschlagen'));
      } on MySqlException catch (e) {
        _log.severe('$e ${_mySqlExceptionText(e)}');
        _errors.add(DatabaseError(DatabaseErrorCategory.create,
            exception: e, description: _mySqlExceptionText(e)));
      }
      freeConn.busy = false;
    });

    return !_listener.isPaused;
  }

  @override
  Future<List<Map<String, dynamic>>> select(String table, {List<String> keys}) async {
    _log.fine('selecting all from "$table"');

    final poolQuery = Query('SELECT ${keys != null ? keys.join(', ') : '*'} FROM $table;');
    _queries.add(poolQuery);

    final result =
        (await _results.stream.firstWhere((PooledResult result) => result.uid == poolQuery.uid))
            .results;
    if (result == null) return null;
    return List.from(result.map<Map<String, dynamic>>((ResultRow e) => e.fields));
  }

  @override
  Future<Map<String, dynamic>> selectSingle(String table, int id) async {
    _log.fine('selecting item with id=$id from "$table"');

    final poolQuery = Query('SELECT * FROM $table WHERE id = $id;');
    _queries.add(poolQuery);

    final result =
        (await _results.stream.firstWhere((PooledResult result) => result.uid == poolQuery.uid))
            .results
            .map<Map<String, dynamic>>((ResultRow e) => e.fields);
    if (result.isNotEmpty) {
      return result.single;
    }
    return null;
  }

  @override
  Future<int> update(String table, int id, Map<String, dynamic> item) async {
    _log.fine('updating $item with id=$id in "$table"');
    final columns = item.keys;
    final values = item.values.toList();
    var cols = '';
    for (var item in columns) {
      cols = '$cols$item=?, ';
    }
    cols = cols.substring(0, cols.length - 2);

    final poolQuery = Query('UPDATE $table SET $cols WHERE id=$id;', values);

    _queries.add(poolQuery);

    return (await _results.stream.firstWhere((PooledResult result) => result.uid == poolQuery.uid))
        .results
        .affectedRows;
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
                    : 'Unbekanntes Verbindungsproblem: $e.';
  }
}

class PooledConnection {
  String uid;
  final MySqlConnection connection;
  bool busy;

  PooledConnection(this.connection, {this.busy = false}) {
    uid = Uuid().v4();
  }

  Map<String, dynamic> get toMap =>
      <String, dynamic>{'uid': uid, 'connection': connection.toString(), 'busy': busy};

  @override
  String toString() => 'PooledConnection [$toMap]';
}

class PooledResult {
  final String uid;
  final Results results;

  PooledResult(this.uid, this.results);
}

class Query {
  String uid;
  final String query;
  final List<dynamic> values;

  Query(this.query, [this.values]) {
    uid = Uuid().v4();
  }
}
