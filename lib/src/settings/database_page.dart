import 'package:flutter/material.dart';

import '../models/mysql_settings.dart';
import '../repositories/settings_repository.dart';

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
                controller: TextEditingController(text: newSettings.host ?? ''),
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Host/IP'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                onChanged: (String input) {
                  if (_formKey.currentState.validate()) newSettings.host = input;
                  dirty = true;
                },
              ),
              TextFormField(
                controller: TextEditingController(text: newSettings.port?.toString() ?? ''),
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
                controller: TextEditingController(text: newSettings.user ?? ''),
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
                controller: TextEditingController(text: newSettings.password ?? ''),
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
                controller: TextEditingController(text: newSettings.database ?? ''),
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
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    repo = SettingsRepository();
    await repo.setUp();
    if (await repo.hasMySqlSettings()) {
      newSettings = await repo.getMySqlSettings();
      setState(() => newSettings);
    }
  }

  @override
  void initState() {
    super.initState();
    newSettings = MySqlSettings(
      host: '127.0.0.1',
      port: 3306,
      database: 'bitter',
      password: '',
      user: '',
    );
    dirty = false;
  }

  void onPopRoute(BuildContext context) async {
    if (!_formKey.currentState.validate() || dirty) {
      var result = await showDialog<int>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(
                    'Wenn du ohne Speichern oder mit unvollständigen Informationen zurück gehst funktioniert das Programm nicht. Bitte vervollständige die Informationen und speichere dann oben rechts.'),
                actions: <Widget>[
                  MaterialButton(onPressed: () => Navigator.pop(context, 1), child: Text('Ok')),
                ],
              ));
      return;
    } else {
      Navigator.pop<bool>(context, false);
    }
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
}
