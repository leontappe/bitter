import 'package:flutter/material.dart';

import '../models/draft.dart';
import '../pages/drafts/draft_creator.dart';

class DraftShortcut extends StatelessWidget {
  final BuildContext context;
  final Draft draft;

  const DraftShortcut(this.context, {Key key, @required this.draft}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0.0,
        color: Theme.of(context).splashColor,
        child: InkWell(
            onTap: () => Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => DraftCreatorPage(draft: draft))),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Entwurf ${draft.id}',
                      style: Theme.of(context).textTheme.subtitle1, textScaleFactor: 1.1),
                  Text('${draft.items.length} Artikel'),
                  Text('${(draft.sum / 100.0).toStringAsFixed(2)} €'),
                ],
              ),
            )));
  }
}
