import 'dart:io';

import 'package:bitter/src/providers/database_provider.dart';
import 'package:bitter/src/providers/inherited_database.dart';
import 'package:bitter/src/repositories/vendor_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../repositories/settings_repository.dart';
import '../../bitter_platform_path_provider.dart';
import '../../widgets/navigation_card.dart';
import '../../widgets/settings_list.dart';
import 'bills_navigation_card.dart';
import 'customers_navigation_card.dart';
import 'drafts_navigation_card.dart';
import 'items_navigation_card.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  PackageInfo packageInfo;

  SettingsRepository settings;
  VendorRepository<DatabaseProvider> vendorRepo;
  List<Vendor> _vendors;
  List<Vendor> filterVendors = [];
  int filterVendor = -1;

  Future<void> onFilter(int value) async {
    setState(() {
      if (value >= 0) {
        filterVendor = value;
      } else {
        filterVendor = null;
      }
    });
    await settings.insert('homepage_filter', filterVendor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bitter Rechnungen'),
        actions: <Widget>[
          Flexible(
              child: DropdownButton<int>(
            value: filterVendor ?? -1,
            dropdownColor: Colors.grey[800],
            iconEnabledColor: Colors.white70,
            style: TextStyle(color: Colors.white, decorationColor: Colors.white70, fontSize: 14.0),
            hint: Text('Nach Verkäufer filtern', style: TextStyle(color: Colors.white)),
            items: <DropdownMenuItem<int>>[
              DropdownMenuItem(child: Text('Filter zurücksetzen'), value: -1),
              ...filterVendors
                  .map((Vendor v) => DropdownMenuItem(value: v.id, child: Text(v.name))),
            ],
            onChanged: onFilter,
          )),
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
          DraftsNavigationCard(filter: filterVendor),
          BillsNavigationCard(filter: filterVendor),
          CustomersNavigationCard(),
          ItemsNavigationCard(filter: filterVendor),
          NavigationCard(
            context,
            '/settings',
            children: <Widget>[
              Text('Einstellungen',
                  style: Theme.of(context).textTheme.headline3, overflow: TextOverflow.ellipsis),
              Divider(),
              SettingsList(context),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> initDb() async {
    settings = SettingsRepository();
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
      return;
    }
    
    if (mounted) {
      vendorRepo = VendorRepository<DatabaseProvider>(
          InheritedDatabase.of<DatabaseProvider>(context).provider);
      await vendorRepo.setUp();
      _vendors = await vendorRepo.select();
    }

    filterVendor = await settings.select<int>('homepage_filter');
    if (mounted) setState(() => filterVendors = _vendors);
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
