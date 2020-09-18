import 'package:flutter/material.dart';

import '../../widgets/settings_list.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
      ),
      body: ListView(children: <Widget>[SettingsList(context)]),
    );
  }
}
