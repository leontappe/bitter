import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'src/pages/bills/bills_list_page.dart';
import 'src/pages/customers/customers_list_page.dart';
import 'src/pages/drafts/drafts_list_page.dart';
import 'src/pages/homepage/homepage.dart';
import 'src/pages/items/items_list_page.dart';
import 'src/pages/settings/app_settings_page.dart';
import 'src/pages/settings/backup_page.dart';
import 'src/pages/settings/settings_page.dart';
import 'src/pages/settings/vendors/vendors_list_page.dart';
import 'src/providers/inherited_database.dart';
import 'src/providers/mysql_provider.dart';
import 'src/providers/sqlite_provider.dart';
import 'src/repositories/settings_repository.dart';
import 'src/util.dart';

void main() async {
  Intl.defaultLocale = 'de_DE';
  await initializeDateFormatting(Intl.defaultLocale);
  runApp(Bitter());
  await startLogging();
}

Future<void> startLogging() async {
  final logPath =
      '${await getLogPath()}/log_${formatDate(DateTime.now()).replaceAll('.', '-')}.txt';
  final logFile = await File(logPath).create(recursive: true);

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    final line = '${record.loggerName}/${record.level.name}: ${record.time}: ${record.message}';
    logFile.writeAsBytesSync(utf8.encode(line + '\n'), mode: FileMode.append);
    if (record.level.value >= 700) print(line);
  });

  Logger('bitter').info('Starting log in $logPath');
}

class Bitter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DbEngine>(
      future: initDb(),
      builder: (BuildContext context, AsyncSnapshot<DbEngine> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return InheritedDatabase(
            provider: (snapshot.data == DbEngine.mysql) ? MySqlProvider() : SqliteProvider(),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'bitter',
              theme: ThemeData(
                primarySwatch: Colors.blueGrey,
                textTheme: TextTheme(
                  headline3: TextStyle(color: Colors.grey[700]),
                  headline4: TextStyle(color: Colors.grey[700], fontSize: 26.0),
                ),
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
                '/settings/backup': (BuildContext context) => BackupPage(),
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
