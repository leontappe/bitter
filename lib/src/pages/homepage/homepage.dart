import 'package:flutter/material.dart';

import '../../../version.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/vendor_repository.dart';
import '../../widgets/database_error_watcher.dart';
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
  SettingsRepository settings;
  VendorRepository<DatabaseProvider> vendorRepo;
  List<Vendor> _vendors;
  List<Vendor> filterVendors = [];
  int filterVendor = -1;

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
              DropdownMenuItem(value: -1, child: Text('Filter zurücksetzen')),
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
                  applicationVersion: version,
                  applicationIcon: Icon(Icons.monetization_on),
                  applicationLegalese: '© 2020 Leon Tappe')),
        ],
      ),
      body: DatabaseErrorWatcher(
        child: ListView(
          children: <Widget>[
            DraftsNavigationCard(filter: filterVendor),
            BillsNavigationCard(filter: filterVendor),
            CustomersNavigationCard(),
            ItemsNavigationCard(filter: filterVendor),
            //WarehouseNavigationCard(filter: filterVendor),
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
      ),
    );
  }

  Future<void> initDb() async {
    settings = SettingsRepository();
    await settings.setUp();
    if (!settings.hasDbEngine() || !settings.hasUsername()) {
      await showDialog<dynamic>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Anwendungseinstellungen festlegen'),
          content: Text(
              'Es ist noch keine Datenbankverbindung eingestellt. Gebe auf der folgenden Seite deinen vollen Namen und die Verbindungsinformationen für den MySQL Server ein um fortzufahren.'),
          actions: <Widget>[
            MaterialButton(
              onPressed: () => Navigator.of(context).popAndPushNamed('/settings/app'),
              child: Text('Fortfahren'),
            ),
          ],
        ),
      );
      return;
    }

    if (mounted) {
      vendorRepo = VendorRepository<DatabaseProvider>(InheritedDatabase.of(context));
      try {
        await vendorRepo.setUp();
        _vendors = await vendorRepo.select(short: true);
      } on NoSuchMethodError catch (e) {
        print('db not availiable $e ${e.stackTrace}');
        return;
      }
    }

    filterVendor = settings.select<int>('homepage_filter');
    if (mounted) setState(() => filterVendors = _vendors);
  }

  @override
  void initState() {
    super.initState();
    initDb();
  }

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
}
