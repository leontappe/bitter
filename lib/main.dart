import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
import 'src/pages/warehouse/warehouse_list_page.dart';
import 'src/providers/inherited_database.dart';
import 'src/providers/mysql_provider.dart';
import 'src/providers/sqlite_provider.dart';
import 'src/repositories/settings_repository.dart';
import 'src/util/format_util.dart';
import 'src/util/path_util.dart';

void main() async {
  Intl.defaultLocale = 'de_DE';
  await initializeDateFormatting(Intl.defaultLocale);
  runApp(Bitter());
  await startLogging();
}

const List<String> mySqlLogNames = [
  'MySqlConnection',
  'BufferedSocket',
  'QueryStreamHandler',
  'StandardDataPacket',
  'PrepareHandler',
  'BinaryDataPacket',
  'ExecuteQueryHandler',
  'AuthHandler',
];

Future<void> startLogging() async {
  String logPath;
  if (kIsWeb) {
    Logger.root.level = Level.FINE; // defaults to Level.INFO
    Logger.root.onRecord.listen(print);
  } else {
    if (Platform.isWindows) {
      logPath =
          '${(await getLogPath()).replaceAll('/', '\\')}\\log_${formatDate(DateTime.now()).replaceAll('.', '-')}.txt';
    } else {
      logPath = '${await getLogPath()}/log_${formatDate(DateTime.now()).replaceAll('.', '-')}.txt';
    }

    final logFile = await File(logPath).create(recursive: true);
    final logSink = logFile.openWrite(mode: FileMode.writeOnlyAppend);

    Logger.root.level = Level.ALL; // defaults to Level.INFO
    Logger.root.onRecord.listen((record) {
      final line = '${record.loggerName}/${record.level.name}: ${record.time}: ${record.message}';
      if (mySqlLogNames.contains(record.loggerName)) {
        return;
      } else {
        logSink.add(utf8.encode(line + '\n'));
      }
      if (record.level.value >= 700) print(line);
    }, onDone: () => logSink.close());
  }

  Logger('bitter').info('Starting log in $logPath');
}

class Bitter extends StatelessWidget {
  final SettingsRepository settingsRepo = SettingsRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DbEngine>(
      future: initDb(),
      builder: (BuildContext context, AsyncSnapshot<DbEngine> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final provider = (snapshot.data == DbEngine.mysql) ? MySqlProvider() : SqliteProvider();
          if (provider is MySqlProvider) {
            final settings = settingsRepo.getMySqlSettings();
            provider.openPool(
              settings.database,
              host: settings.host,
              port: settings.port,
              user: settings.user,
              password: settings.password,
            );
          }
          return InheritedDatabase(
            provider: provider,
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
                '/warehouse': (BuildContext context) => WarehouseListPage(),
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
    await settingsRepo.setUp();
    return settingsRepo.getDbEngine();
  }
}
