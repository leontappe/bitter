import '../models/mysql_settings.dart';
import '../providers/inherited_database.dart';
import '../providers/mysql_provider.dart';
import '../repositories/settings_repository.dart';
import 'package:flutter/material.dart';

class DatabasePage extends StatefulWidget {
  @override
  _DatabasePageState createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SettingsRepository repo;

  MySqlSettings settings;
  MySqlSettings newSettings;

  bool dirty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) =>
                IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => onPopRoute(context))),
        title: Text('Datenbankeinstellungen'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: onSaveConfig,
              tooltip: 'Einstellungen abspeichern'),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Form(
          key: _formKey,
          child: ListView(
            itemExtent: 64.0,
            children: <Widget>[
              TextFormField(
                initialValue: newSettings.host,
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Host/IP'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                onChanged: (String input) {
                  if (_formKey.currentState.validate()) newSettings.host = input;
                  dirty = true;
                },
              ),
              TextFormField(
                initialValue: newSettings.port.toString(),
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Port'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                keyboardType: TextInputType.numberWithOptions(),
                onChanged: (String input) {
                  newSettings.port = int.parse(input);
                  _formKey.currentState.validate();
                  dirty = true;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Nutzer'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                onChanged: (String input) {
                  newSettings.user = input;
                  _formKey.currentState.validate();
                  dirty = true;
                },
              ),
              TextFormField(
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Passwort'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                obscureText: true,
                onChanged: (String input) {
                  newSettings.password = input;
                  _formKey.currentState.validate();
                  dirty = true;
                },
              ),
              TextFormField(
                initialValue: newSettings.database,
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Datenbankname'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                onChanged: (String input) {
                  newSettings.database = input;
                  _formKey.currentState.validate();
                  dirty = true;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    repo = SettingsRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    dirty = false;
    newSettings = MySqlSettings(
      host: '127.0.0.1',
      port: 3306,
      database: 'bitter',
      password: null,
      user: null,
    );
  }

  Future<bool> onSaveConfig() async {
    if (_formKey.currentState.validate()) {
      settings = newSettings;
      await repo.setMySqlSettings(settings);
      dirty = false;
      return true;
    }
    return false;
  }

  void onPopRoute(BuildContext context) async {
    if (dirty) {
      var result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                    'Wenn du ohne Speichern fortfährst gehen alle hier eingebenen Daten verloren. Vor dem Verlassen abspeichern?'),
                actions: <Widget>[
                  MaterialButton(
                      onPressed: () => Navigator.pop(context, -1), child: Text('Abbrechen')),
                  MaterialButton(onPressed: () => Navigator.pop(context, 0), child: Text('Nein')),
                  MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Ja')),
                ],
              ));
      switch (result) {
        case 0:
          Navigator.pop<bool>(context, false);
          break;
        case 1:
          if (!await onSaveConfig()) {
            Scaffold.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Es gibt noch Fehler und/oder fehlende Felder in dem Formular, sodass gerade nicht gespeichert werden kann.'),
              duration: Duration(seconds: 3),
            ));
          }
          break;
        default:
          return;
      }
    } else {
      Navigator.pop<bool>(context, false);
    }
  }
}
