abstract class DatabaseProvider {
  Future<int> delete(String table, int id);

  Future<int> insert(String table, Map item);

  Future<void> open(String path, {String host, int port, String user, String password});

  Future<List<Map>> select(String table);

  Future<Map> selectSingle(String table, int id);

  Future<int> update(String table, int id, Map item);

  Future<void> createTable(
      String table, List<String> columns, List<String> types, String primaryKey,
      {List<bool> nullable});
}
