import '../models/database_error.dart';

abstract class DatabaseProvider {
  Stream<DatabaseError> get errors;

  Future<void> createTable(
      String table, List<String> columns, List<String> types, String primaryKey,
      {List<bool> nullable});

  Future<int> delete(String table, int id);

  Future<void> dropTable(String table);

  Future<int> insert(String table, Map<String, dynamic> item);

  Future<bool> open(String path, {String host, int port, String user, String password});

  Future<List<Map<String, dynamic>>> select(String table, {List<String> keys});

  Future<Map<String, dynamic>> selectSingle(String table, int id);

  Future<int> update(String table, int id, Map<String, dynamic> item);

  Future<void> close();
}

mixin PooledDatabaseProvider on DatabaseProvider {
  Future<bool> openPool(String path,
      {String host, int port, String user, String password, int size});
}
