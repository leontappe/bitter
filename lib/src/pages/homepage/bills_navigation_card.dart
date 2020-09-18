import 'package:flutter/material.dart';

import '../../widgets/navigation_card.dart';

class BillsNavigationCard extends StatefulWidget {
  @override
  _BillsNavigationCardState createState() => _BillsNavigationCardState();
}

class _BillsNavigationCardState extends State<BillsNavigationCard> {
  @override
  Widget build(BuildContext context) {
    return NavigationCard(
      context,
      '/bills',
      children: <Widget>[
        Text('Rechnungen', style: Theme.of(context).textTheme.headline3),
      ],
    );
  }
}
