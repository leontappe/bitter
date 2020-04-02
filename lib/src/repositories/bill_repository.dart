import '../mysql_credentials.dart';
import '../providers/database_provider.dart';

const String tableName = 'bills';

class BillRepository<T extends DatabaseProvider> {
  final T db;

  BillRepository(this.db);

  //TODO: the rest

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
      ['id', 'bill_nr', 'file', 'created'],
      ['INTEGER', 'TEXT', 'TEXT', 'DATETIME'],
      'id',
      nullable: <bool>[true, false, false, false],
    );
  }
}
