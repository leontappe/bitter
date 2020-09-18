import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../repositories/settings_repository.dart';
import '../../bitter_platform_path_provider.dart';
import '../../widgets/navigation_card.dart';
import 'bills_navigation_card.dart';
import 'drafts_navigation_card.dart';

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
          DraftsNavigationCard(),
          BillsNavigationCard(),
          NavigationCard(
            context,
            '/customers',
            children: <Widget>[
              Text('Kunden',
                  style: Theme.of(context).textTheme.headline3, overflow: TextOverflow.ellipsis)
            ],
          ),
          NavigationCard(
            context,
            '/items',
            children: <Widget>[
              Text('Artikel',
                  style: Theme.of(context).textTheme.headline3, overflow: TextOverflow.ellipsis)
            ],
          ),
          NavigationCard(
            context,
            '/settings',
            children: <Widget>[
              Text('Einstellungen',
                  style: Theme.of(context).textTheme.headline3, overflow: TextOverflow.ellipsis)
            ],
          ),
        ],
      ),
    );
  }

  Future<void> initDb() async {
    final settings = SettingsRepository();
    await settings.setUp();
    if (!await settings.hasDbEngine() || !await settings.hasUsername()) {
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
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      packageInfo = await PackageInfo.fromPlatform();
    }
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    initPackageInfo();
    PathProviderPlatform.instance = BitterPlatformPathProvider();
  }
}
