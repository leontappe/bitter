import 'package:bitter/src/providers/mysql_provider.dart';
import 'package:bitter/src/repositories/customer_repository.dart';

void main() async {
  final c = CustomerRepository(MySqlProvider());

  await c.setUp();

  print(await c.select());
}
