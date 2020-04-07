import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
      ),
      body: ListView(children: <Widget>[
        ListTile(
          title: Text('Verkäufer', style: Theme.of(context).textTheme.headline6),
          subtitle:
              Text('Editieren und Erstellen verschiendener Identitäten zur Rechnungsstellung'),
          onTap: () => Navigator.pushNamed(context, '/settings/vendors'),
        ),
        ListTile(
          title: Text('Datenbankeinstellungen', style: Theme.of(context).textTheme.headline6),
          subtitle: Text('Einstellen der Datenbankverbindung'),
          onTap: () => Navigator.pushNamed(context, '/settings/database'),
        ),
      ]),
    );
  }
}
