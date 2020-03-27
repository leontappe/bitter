import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'providers/inherited_database.dart';
import 'providers/mysql_provider.dart';
import 'repositories/customer_repository.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bitter Rechnungen'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.info),
              onPressed: () => showAboutDialog(
                  context: context,
                  applicationName: 'bitter Rechnungen',
                  applicationVersion: packageInfo?.version ?? 'unidentified non-mobile version',
                  applicationIcon: Icon(Icons.monetization_on),
                  applicationLegalese: '© 2020 Leon Tappe'))
        ],
      ),
      body: ListView(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(8.0),
            child: InkWell(
              splashColor: Theme.of(context).accentColor.withAlpha(30),
              onTap: () {
                Navigator.pushNamed(context, '/customers');
              },
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[Text('Kunden', style: Theme.of(context).textTheme.headline3)],
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(8.0),
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                Navigator.pushNamed(context, '/bills');
              },
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Rechnungen', style: Theme.of(context).textTheme.headline3)
                  ],
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(8.0),
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Einstellungen', style: Theme.of(context).textTheme.headline3)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initDb() async {
    final repo = CustomerRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    await repo.setUp();
  }

  void initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) if (Platform.isAndroid || Platform.isIOS) initPackageInfo();
  }
}
