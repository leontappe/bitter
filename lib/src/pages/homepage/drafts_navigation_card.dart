import 'package:flutter/material.dart';

import '../../models/draft.dart';
import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/draft_repository.dart';
import '../../widgets/draft_shortcut.dart';
import '../../widgets/navigation_card.dart';
import '../drafts/draft_creator.dart';

class DraftsNavigationCard extends StatefulWidget {
  @override
  _DraftsNavigationCardState createState() => _DraftsNavigationCardState();
}

class _DraftsNavigationCardState extends State<DraftsNavigationCard> {
  DraftRepository _billRepo;
  List<Draft> _drafts = [];

  @override
  Widget build(BuildContext context) {
    return NavigationCard(
      context,
      '/drafts',
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Entwürfe', style: Theme.of(context).textTheme.headline3),
            IconButton(
                tooltip: 'Neuen Entwurf erstellen',
                icon: Icon(Icons.note_add, color: Colors.grey[700]),
                onPressed: () => Navigator.push<bool>(context,
                    MaterialPageRoute<bool>(builder: (BuildContext context) => DraftCreatorPage())))
          ],
        ),
        Divider(),
        Text('Neu', style: Theme.of(context).textTheme.headline4),
        Flexible(
            child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ..._drafts.take(4).map<Widget>(
                  (Draft d) => Expanded(child: DraftShortcut(context, draft: d)),
                ),
            if (_drafts.length > 4)
              Center(child: Icon(Icons.more_horiz, color: Colors.grey, size: 48.0)),
            for (var i = 0; i < (4 - _drafts.length); i++) Spacer(),
          ],
        )),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    initDb();
    super.didChangeDependencies();
  }

  Future<void> initDb() async {
    _billRepo = DraftRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    await _billRepo.setUp();

    await onGetDrafts();
  }

  Future<void> onGetDrafts() async {
    _drafts = await _billRepo.select();
    _drafts.sort((Draft a, Draft b) => b.id.compareTo(a.id));
    setState(() => _drafts);
    return;
  }
}
