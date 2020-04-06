import '../models/draft.dart';
import '../providers/inherited_database.dart';
import '../providers/mysql_provider.dart';
import '../repositories/draft_repository.dart';
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
        semanticChildCount: 4,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(title: Text('Entwürfe', style: Theme.of(context).textTheme.headline6)),
              Divider(height: 0.0),
              ...drafts.map((Draft d) => ListTile(title: Text('Entwurf ${d.id}'))),
            ],
          ),
          Divider(height: 4.0),
          Divider(height: 4.0),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(title: Text('Rechnungen', style: Theme.of(context).textTheme.headline6)),
              Divider(height: 0.0),
            ],
          )
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
