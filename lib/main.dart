import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'src/homepage.dart';
import 'src/pages/bills/bills_list_page.dart';
import 'src/pages/customers/customers_list_page.dart';
import 'src/pages/drafts/drafts_list_page.dart';
import 'src/pages/items/items_list_page.dart';
import 'src/pages/settings/app_settings_page.dart';
import 'src/pages/settings/settings_page.dart';
import 'src/pages/settings/vendors/vendors_list_page.dart';
import 'src/providers/database_provider.dart';
import 'src/providers/inherited_database.dart';
import 'src/providers/mysql_provider.dart';
import 'src/providers/sqlite_provider.dart';
import 'src/repositories/settings_repository.dart';

void main() {
  Intl.defaultLocale = 'de_DE';
  runApp(Bitter());
}

class Bitter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DbEngine>(
      future: initDb(),
      builder: (BuildContext context, AsyncSnapshot<DbEngine> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return InheritedDatabase<DatabaseProvider>(
            provider: (snapshot.data == DbEngine.mysql) ? MySqlProvider() : SqliteProvider(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'bitter',
              theme: ThemeData(
                primarySwatch: Colors.blueGrey,
              ),
              initialRoute: '/home',
              routes: <String, Widget Function(BuildContext)>{
                '/bills': (BuildContext context) => BillsListPage(),
                '/customers': (BuildContext context) => CustomersListPage(),
                '/drafts': (BuildContext context) => DraftsListPage(),
                '/home': (BuildContext context) => Homepage(),
                '/items': (BuildContext context) => ItemsListPage(),
                '/settings': (BuildContext context) => SettingsPage(),
                '/settings/app': (BuildContext context) => AppSettingsPage(),
                '/settings/vendors': (BuildContext context) => VendorsPage(),
              },
            ),
          );
        } else {
          return Container(width: 0.0, height: 0.0);
        }
      },
    );
  }

  Future<DbEngine> initDb() async {
    final settings = SettingsRepository();
    await settings.setUp();
    return settings.getDbEngine();
  }
}
