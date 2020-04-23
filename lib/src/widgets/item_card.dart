import 'package:bitter/src/models/item.dart';
import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({Key key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      elevation: 8.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Artikelnummer ' + item.itemId.toString(), style: Theme.of(context).textTheme.headline5),
            Text(item.title, style: Theme.of(context).textTheme.headline5),
          ],
        ),
      ),
    );
  }
}
