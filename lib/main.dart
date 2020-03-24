import 'package:bitter/src/customers/customers_list_page.dart';
import 'package:bitter/src/providers/inherited_provider.dart';
import 'package:bitter/src/providers/mysql_customer_provider.dart';
import 'package:flutter/material.dart';

import 'src/bills/bills_list_page.dart';
import 'src/homepage.dart';
import 'src/customers/customers_list_page.dart';
import 'src/models/customer.dart';

void main() => runApp(Bitter());

class Bitter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InheritedProvider<Customer>(
      provider: MySQLCustomerProvider(),
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
