import 'dart:io';

import 'package:flutter/material.dart';

import '../../repositories/settings_repository.dart';

class AppSettingsPage extends StatefulWidget {
  @override
  _AppSettingsPageState createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final GlobalKey<FormState> _usernameFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _databaseFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _sqliteFormKey = GlobalKey<FormState>();

  SettingsRepository repo;

  MySqlSettings mysqlSettings;
  String username;
  DbEngine dbEngine;
  String sqliteName;

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
                    value: DbEngine.sqlite,
                    child: Text('SQLite'),
                  ),
                  DropdownMenuItem<DbEngine>(
                    value: DbEngine.mysql,
                    child: Text('MySQL'),
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
                      controller: TextEditingController(text: mysqlSettings.host ?? ''),
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Host/IP'),
                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                      onChanged: (String input) {
                        mysqlSettings.host = input;
                        _databaseFormKey.currentState.validate();
                        dirty = true;
                      },
                    ),
                    TextFormField(
                      controller: TextEditingController(text: mysqlSettings.port?.toString() ?? ''),
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Port'),
                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                      keyboardType: TextInputType.numberWithOptions(),
                      onChanged: (String input) {
                        mysqlSettings.port = int.parse(input);
                        _databaseFormKey.currentState.validate();
                        dirty = true;
                      },
                    ),
                    TextFormField(
                      controller: TextEditingController(text: mysqlSettings.user ?? ''),
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Nutzer'),
                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                      onChanged: (String input) {
                        mysqlSettings.user = input;
                        _databaseFormKey.currentState.validate();
                        dirty = true;
                      },
                    ),
                    TextFormField(
                      controller: TextEditingController(text: mysqlSettings.password ?? ''),
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Passwort'),
                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                      obscureText: true,
                      onChanged: (String input) {
                        mysqlSettings.password = input;
                        _databaseFormKey.currentState.validate();
                        dirty = true;
                      },
                    ),
                    TextFormField(
                      controller: TextEditingController(text: mysqlSettings.database ?? ''),
                      maxLines: 1,
                      decoration: InputDecoration(labelText: 'Datenbankname'),
                      validator: (input) => input.isEmpty ? 'Pflichtfeld' : null,
                      onChanged: (String input) {
                        mysqlSettings.database = input;
                        _databaseFormKey.currentState.validate();
                        dirty = true;
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (dbEngine == DbEngine.sqlite)
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              child: Form(
                key: _sqliteFormKey,
                child: TextFormField(
                  controller: TextEditingController(text: sqliteName ?? ''),
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Datenbankname'),
                  validator: (input) => input.isEmpty
                      ? 'Pflichtfeld'
                      : input.contains(' ')
                          ? 'Keine Leerzeichen oder Sonderzeichen nutzen'
                          : null,
                  onChanged: (String input) {
                    sqliteName = input;
                    _sqliteFormKey.currentState.validate();
                    dirty = true;
                  },
                ),
              ),
            ),
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
    mysqlSettings = repo.getMySqlSettings();
    username = repo.getUsername() ?? '';
    sqliteName = repo.getSqliteName();
    if (!Platform.isWindows) {
      dbEngine = repo.getDbEngine() ?? DbEngine.sqlite;
    } else {
      await repo.setDbEngine(dbEngine);
    }
    if (mounted) setState(() => mysqlSettings);
  }

  @override
  void initState() {
    super.initState();
    mysqlSettings = MySqlSettings.standard();
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
      await repo.setUsername(username);
      if (dbEngine == DbEngine.sqlite) {
        await repo.setSqliteName(sqliteName);
      } else {
        await repo.setMySqlSettings(mysqlSettings);
      }
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
