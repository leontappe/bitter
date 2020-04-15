import 'package:bitter/src/models/item.dart';
import 'package:flutter/material.dart';

class ItemsCard extends StatelessWidget {
  final List<Item> items;
  final int sum;

  const ItemsCard({Key key, @required this.items, @required this.sum}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Name', style: Theme.of(context).textTheme.bodyText1),
              Text('Menge', style: Theme.of(context).textTheme.bodyText1),
              Text('Ust.', style: Theme.of(context).textTheme.bodyText1),
              Text('Einzelpreis', style: Theme.of(context).textTheme.bodyText1),
              Text('Nettopreis', style: Theme.of(context).textTheme.bodyText1),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.all(16.0),
          elevation: 8.0,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ...items.map(
                  (Item i) => Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(i.title),
                              if (i.description != null && i.description.isNotEmpty)
                                Text(i.description),
                            ],
                          ),
                          Text('${i.quantity}x'),
                          Text('${i.tax}%'),
                          Text((i.price / 100.0).toStringAsFixed(2) + '€'),
                          Text((i.sum / 100.0).toStringAsFixed(2) + '€'),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Summe', style: Theme.of(context).textTheme.subtitle2),
              Text((sum / 100.0).toStringAsFixed(2) + '€',
                  style: Theme.of(context).textTheme.subtitle2),
            ],
          ),
        ),
      ],
    );
  }
}
