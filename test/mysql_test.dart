import 'package:bitter/src/providers/mysql_provider.dart';
import 'package:bitter/src/repositories/customer_repository.dart';
import 'package:logging/logging.dart';

void main() async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    final line = '${record.loggerName}/${record.level.name}: ${record.time}: ${record.message}';
    if (record.level.value >= 700) print(line);
  });

  final mysql = MySqlProvider();
  await mysql.openPool('bitter',
      host: 'host', port: 3306, password: 'password', user: 'user', size: 10);
  final c = CustomerRepository(mysql);

  await c.setUp();

  while (true) {
    print(await c.select());
  }
}
