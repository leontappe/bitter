import 'package:bitter/src/models/draft.dart';

import '../mysql_credentials.dart';
import '../providers/database_provider.dart';

const String tableName = 'drafts';

class DraftRepository<T extends DatabaseProvider> {
  final T db;

  DraftRepository(this.db);

  Future<void> delete(int id) {
    return db.delete(tableName, id);
  }

  Future<Draft> insert(Draft draft) async {
    draft.id = await db.insert(tableName, draft.toMap);
    return draft;
  }

  Future<List<Draft>> select({String searchQuery}) async {
    final results =
        List<Draft>.from((await db.select(tableName)).map<Draft>((Map e) => Draft.fromMap(e)));
    if (searchQuery != null && searchQuery.isNotEmpty) {
      return List.from(
          results.where((Draft d) => (d.billNr).toLowerCase().contains(searchQuery.toLowerCase())));
    } else {
      return results;
    }
  }

  Future<Draft> selectSingle(int id) async {
    return Draft.fromMap(await db.selectSingle(tableName, id));
  }

  Future<void> setUp() async {
    await db.open(
      mySqlSettings.database,
      host: mySqlSettings.host,
      port: mySqlSettings.port,
      user: mySqlSettings.user,
      password: mySqlSettings.password,
    );

    await db.createTable(
      tableName,
      ['id', 'bill_nr', 'editor', 'customer', 'vendor', 'items', 'tax'],
      ['INTEGER', 'TEXT', 'TEXT', 'INTEGER', 'INTEGER', 'TEXT', 'INTEGER'],
      'id',
      nullable: <bool>[true, false, false, false, false, false, false],
    );
  }

  Future<void> update(Draft draft) {
    return db.update(tableName, draft.id, draft.toMap);
  }
}
