import 'package:bitter/src/models/draft.dart';
import 'package:bitter/src/providers/inherited_database.dart';
import 'package:bitter/src/providers/mysql_provider.dart';
import 'package:bitter/src/repositories/draft_repository.dart';
import 'package:flutter/material.dart';

import 'draft_creator.dart';

class BillsListPage extends StatefulWidget {
  @override
  _BillsListPageState createState() => _BillsListPageState();
}

class _BillsListPageState extends State<BillsListPage> {
  DraftRepository<MySqlProvider> repo;

  List<Draft> drafts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rechnungen'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Neue Rechnung erstellen',
            icon: Icon(Icons.note_add),
            onPressed: onPushDraftCreator,
          )
        ],
      ),
      body: ListView(
        semanticChildCount: drafts.length,
        children: <Widget>[
          ...drafts.map((Draft d) => ListTile(title: Text(d.billNr))),
        ],
      ),
    );
  }

  Future<void> initDb() async {
    repo = DraftRepository(InheritedDatabase.of<MySqlProvider>(context).provider);
    await repo.setUp();

    await onGetDrafts();
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> onGetDrafts() async {
    drafts = await repo.select();
    setState(() => drafts);
  }

  Future<void> onPushDraftCreator() async {
    final updated = await Navigator.push<bool>(
        context, MaterialPageRoute<bool>(builder: (BuildContext context) => DraftCreatorPage()));
    if (updated) {
      await onGetDrafts();
    }
  }
}
