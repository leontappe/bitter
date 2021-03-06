import 'package:flutter/material.dart';

class SettingsList extends StatelessWidget {
  final BuildContext context;

  const SettingsList(this.context, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Verkäufer', style: Theme.of(context).textTheme.headline6),
          subtitle:
              Text('Editieren und Erstellen verschiendener Identitäten zur Rechnungsstellung'),
          onTap: () => Navigator.pushNamed(context, '/settings/vendors'),
        ),
        ListTile(
          title: Text('Anwendungseinstellungen', style: Theme.of(context).textTheme.headline6),
          subtitle: Text('Einstellen der Datenbankverbindung und der Bearbeiter*in'),
          onTap: () => Navigator.pushNamed(context, '/settings/app'),
        ),
        ListTile(
          title: Text('Backup und Wiederherstellung', style: Theme.of(context).textTheme.headline6),
          subtitle: Text('Export und Sicherung der Datenbank'),
          onTap: () => Navigator.pushNamed(context, '/settings/backup'),
        ),
      ],
    );
  }
}
