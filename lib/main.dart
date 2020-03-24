import 'package:flutter/material.dart';

import 'src/bills/bills_list_page.dart';
import 'src/customers/customers_list_page.dart';
import 'src/homepage.dart';
import 'src/providers/inherited_database.dart';
import 'src/providers/mysql_provider.dart';

void main() => runApp(Bitter());

class Bitter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InheritedDatabase<MySqlProvider>(
      provider: MySqlProvider(),
      child: MaterialApp(
        title: 'bitter',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        initialRoute: 'home',
        routes: <String, Widget Function(BuildContext)>{
          'home': (BuildContext context) => Homepage(),
          'customers': (BuildContext context) => CustomersListPage(),
          'bills': (BuildContext context) => BillsListPage(),
        },
      ),
    );
  }
}
