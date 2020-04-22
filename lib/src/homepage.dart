import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'repositories/settings_repository.dart';
import 'bitter_platform_path_provider.dart';

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
              tooltip: 'Informationen über die App anzeigen',
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
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                Navigator.pushNamed(context, '/drafts');
              },
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Entwürfe', style: Theme.of(context).textTheme.headline3)
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
    final settings = SettingsRepository();
    await settings.setUp();
    if (!await settings.hasMySqlSettings() || !await settings.hasUsername()) {
      await showDialog<dynamic>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Anwendungseinstellungen festlegen'),
          content: Text(
              'Es ist noch keine Datenbankverbindung eingestellt. Gebe auf der folgenden Seite deinen vollen Namen und die Verbindungsinformationen für den MySQL Server ein um fortzufahren.'),
          actions: <Widget>[
            MaterialButton(
              child: Text('Fortfahren'),
              onPressed: () => Navigator.of(context).popAndPushNamed('/settings/app'),
            ),
          ],
        ),
      );
    }
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
    PathProviderPlatform.instance = BitterPlatformPathProvider();
  }
}
