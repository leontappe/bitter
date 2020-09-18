import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../pages/bills/bill_page.dart';

class BillShortcut extends StatelessWidget {
  final BuildContext context;
  final Bill bill;

  const BillShortcut(this.context, {Key key, @required this.bill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0.0,
        color: Theme.of(context).splashColor,
        child: InkWell(
            onTap: () => Navigator.push<bool>(context,
                MaterialPageRoute(builder: (BuildContext context) => BillPage(id: bill.id))),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(bill.billNr,
                      style: Theme.of(context).textTheme.subtitle1,
                      textScaleFactor: 1.1,
                      overflow: TextOverflow.ellipsis),
                  Text(bill.vendor.name, overflow: TextOverflow.ellipsis),
                  Text(bill.customer.fullCompany ?? bill.customer.fullName,
                      overflow: TextOverflow.ellipsis),
                  Text('${bill.items.length} Artikel', overflow: TextOverflow.ellipsis),
                  Text((bill.sum / 100.0).toStringAsFixed(2) + ' €',
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            )));
  }
}
