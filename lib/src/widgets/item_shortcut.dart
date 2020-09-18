import 'package:flutter/material.dart';

import '../models/item.dart';
import '../pages/customers/customer_page.dart';

class ItemShortcut extends StatelessWidget {
  final BuildContext context;
  final Item item;

  const ItemShortcut(this.context, {Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0.0,
        color: Theme.of(context).splashColor,
        child: InkWell(
            onTap: () => Navigator.push<bool>(context,
                MaterialPageRoute(builder: (BuildContext context) => CustomerPage(id: item.id))),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.title,
                      style: Theme.of(context).textTheme.subtitle1,
                      textScaleFactor: 1.1,
                      overflow: TextOverflow.ellipsis),
                  Text(item.description, overflow: TextOverflow.ellipsis),
                  Text('${(item.price / 100.0).toStringAsFixed(2)} €',
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            )));
  }
}
