import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/mysql_settings.dart';
import '../../repositories/settings_repository.dart';

class AppSettingsPage extends StatefulWidget {
  @override
  _AppSettingsPageState createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final GlobalKey<FormState> _usernameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _databaseFormKey = GlobalKey<FormState>();

  SettingsRepository repo;

  MySqlSettings settings;
  String username;
  DbEngine dbEngine;

  bool dirty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
            builder: (BuildContext context) => IconButton(
                  tooltip: 'Zurück',
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () => onPopRoute(context),
                )),
        title: Text('Anwendungseinstellungen'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Einstellungen abspeichern',
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: onSaveConfig,
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(title: Text('Anwender', style: Theme.of(context).textTheme.headline6)),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: Form(
              key: _usernameFormKey,
              child: TextFormField(
                controller: TextEditingController(text: username ?? ''),
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Anwendername'),
                validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                onChanged: (String input) {
                  username = input;
                  _usernameFormKey.currentState.validate();
                  dirty = true;
                },
              ),
            ),
          ),
          ListTile(title: Text('Datenbank', style: Theme.of(context).textTheme.headline6)),
          if (!Platform.isWindows)
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: DropdownButton<DbEngine>(
                value: dbEngine,
                items: <DropdownMenuItem<DbEngine>>[
                  DropdownMenuItem<DbEngine>(
                    child: Text('SQLite'),
                    value: DbEngine.sqlite,
                  ),
                  DropdownMenuItem<DbEngine>(
                    child: Text('MySQL'),
                    value: DbEngine.mysql,
                  ),
                ],
                onChanged: (DbEngine engine) {
                  setState(() {
                    dbEngine = engine;
                  });
                  dirty = true;
                },
              ),
            ),
          if (dbEngine == DbEngine.mysql)
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: Form(
                key: _databaseFormKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: TextEditingController(text: settings.host ?? ''),
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Host/IP'),
                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                      onChanged: (String input) {
                        if (_databaseFormKey.currentState.validate()) settings.host = input;
                        dirty = true;
                      },
                    ),
                    TextFormField(
                      controller: TextEditingController(text: settings.port?.toString() ?? ''),
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Port'),
                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                      keyboardType: TextInputType.numberWithOptions(),
                      onChanged: (String input) {
                        settings.port = int.parse(input);
                        _databaseFormKey.currentState.validate();
                        dirty = true;
                      },
                    ),
                    TextFormField(
                      controller: TextEditingController(text: settings.user ?? ''),
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Nutzer'),
                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                      onChanged: (String input) {
                        settings.user = input;
                        _databaseFormKey.currentState.validate();
                        dirty = true;
                      },
                    ),
                    TextFormField(
                      controller: TextEditingController(text: settings.password ?? ''),
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Passwort'),
                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                      obscureText: true,
                      onChanged: (String input) {
                        settings.password = input;
                        _databaseFormKey.currentState.validate();
                        dirty = true;
                      },
                    ),
                    TextFormField(
                      controller: TextEditingController(text: settings.database ?? ''),
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Datenbankname'),
                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                      onChanged: (String input) {
                        settings.database = input;
                        _databaseFormKey.currentState.validate();
                        dirty = true;
                      },
                    ),
                  ],
                ),
              ),
            )
        ],
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
    settings = await repo.getMySqlSettings();
    username = await repo.getUsername() ?? '';
    if (!Platform.isWindows) {
      dbEngine = await repo.getDbEngine() ?? DbEngine.sqlite;
    } else {
      await repo.setDbEngine(dbEngine);
    }
    if (mounted) setState(() => settings);
  }

  @override
  void initState() {
    super.initState();
    settings = MySqlSettings.standard();
    dirty = false;
    if (Platform.isWindows) {
      dbEngine = DbEngine.mysql;
    } else {
      dbEngine = DbEngine.sqlite;
    }
  }

  void onPopRoute(BuildContext context) async {
    if (!((dbEngine == DbEngine.sqlite) ? true : _databaseFormKey.currentState.validate()) ||
        !_usernameFormKey.currentState.validate() ||
        dirty) {
      await showDialog<int>(
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
    if (((dbEngine == DbEngine.sqlite) ? true : _databaseFormKey.currentState.validate()) &&
        _usernameFormKey.currentState.validate()) {
      await repo.setMySqlSettings(settings);
      await repo.setUsername(username);
      if (repo.getDbEngine() != null && repo.getDbEngine() != dbEngine) {
        await repo.insert('bills_filter', null);
        await repo.insert('drafts_filter', null);
        await repo.insert('items_filter', null);
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Datenbank geändert'),
            content: Text(
                'Nach dem Ändern der Datenbank muss bitter neu gestartet werden damit die Änderung wirksam wird. Bis dahin funktionieren die alten Einstellungen normal.'),
            actions: [
              MaterialButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Weiter'),
              )
            ],
          ),
        );
      }
      await repo.setDbEngine(dbEngine);
      dirty = false;
      return true;
    }
    return false;
  }
}
