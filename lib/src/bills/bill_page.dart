import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../widgets/customer_card.dart';
import '../widgets/items_card.dart';
import '../widgets/vendor_card.dart';

class BillPage extends StatefulWidget {
  final Bill bill;

  BillPage({this.bill});

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill.billNr),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(widget.bill.billNr, style: Theme.of(context).textTheme.headline6),
            subtitle:
                Text('Erstellt am ${widget.bill.created.toLocal().toString().split('.').first}'),
            trailing: Text('von ${widget.bill.editor}'),
          ),
          ListTile(
            title: Text('Verkäufer', style: Theme.of(context).textTheme.headline6),
            subtitle: VendorCard(vendor: widget.bill.vendor),
          ),
          ListTile(
            title: Text('Kunde', style: Theme.of(context).textTheme.headline6),
            subtitle: CustomerCard(customer: widget.bill.customer),
          ),
          ListTile(
            title: Text('Artikel', style: Theme.of(context).textTheme.headline6),
            subtitle: ItemsCard(items: widget.bill.items, sum: widget.bill.sum),
          ),
        ],
      ),
    );
  }
}
