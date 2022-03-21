import 'package:flutter/material.dart';

import '../../providers/inherited_database.dart';
import '../../repositories/customer_repository.dart';
import '../../widgets/navigation_card.dart';
import '../../widgets/shortcuts/customer_shortcut.dart';
import '../customers/customer_page.dart';

class CustomersNavigationCard extends StatefulWidget {
  @override
  _CustomersNavigationCardState createState() => _CustomersNavigationCardState();
}

class _CustomersNavigationCardState extends State<CustomersNavigationCard> {
  CustomerRepository _customerRepo;

  List<Customer> _customers = [];

  @override
  Widget build(BuildContext context) {
    return NavigationCard(
      context,
      '/customers',
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text('Kunden',
                    style: Theme.of(context).textTheme.headline5, overflow: TextOverflow.ellipsis)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    tooltip: 'Neuen Kunden erstellen',
                    icon: Icon(Icons.add, color: Colors.grey[700]),
                    onPressed: () async {
                      await Navigator.push<bool>(
                          context,
                          MaterialPageRoute<bool>(
                              builder: (BuildContext context) => CustomerPage()));
                      await onRefresh();
                    }),
                IconButton(
                    tooltip: 'Aktualisieren',
                    icon: Icon(Icons.refresh, color: Colors.grey[800]),
                    onPressed: () => onRefresh()),
              ],
            )
          ],
        ),
        Divider(),
        Text('Neu', style: Theme.of(context).textTheme.headline6),
        Text(
          'Zurzeit ${_customers.length == 1 ? 'ist' : 'sind'} ${_customers.length} Kunde${_customers.length == 1 ? '' : 'n'} vorhanden.',
          style: TextStyle(color: Colors.grey[800]),
          overflow: TextOverflow.ellipsis,
        ),
        if (_customers.isNotEmpty)
          Flexible(
              child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(height: 77.0, width: 0.0),
              ..._customers.take(4).map<Widget>((Customer c) => Expanded(
                    child: CustomerShortcut(context, customer: c),
                  )),
              if (_customers.length > 4)
                Center(child: Icon(Icons.more_horiz, color: Colors.grey, size: 48.0))
              else if (_customers.isNotEmpty)
                Container(width: 48.0, height: 48.0),
              for (var i = 0; i < (4 - _customers.length); i++) Spacer(),
            ],
          )),
      ],
    );
  }

  Future<void> initDb() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    _customerRepo = CustomerRepository(InheritedDatabase.of(context));

    try {
      await _customerRepo.setUp();
      await onRefresh();
    } on NoSuchMethodError {
      print('db not availiable');
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> onRefresh() async {
    _customers = await _customerRepo.select();
    _customers.sort((Customer a, Customer b) => b.id.compareTo(a.id));
    if (mounted) setState(() => _customers);
  }
}
