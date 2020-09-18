import 'package:flutter/material.dart';

import '../../providers/database_provider.dart';
import '../../providers/inherited_database.dart';
import '../../repositories/customer_repository.dart';
import '../../widgets/shortcuts/customer_shortcut.dart';
import '../../widgets/navigation_card.dart';
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
                    style: Theme.of(context).textTheme.headline3, overflow: TextOverflow.ellipsis)),
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
        Text('Neu', style: Theme.of(context).textTheme.headline4),
        Flexible(
            child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ..._customers.take(4).map<Widget>((Customer c) => Expanded(
                  child: CustomerShortcut(context, customer: c),
                )),
            if (_customers.length > 4)
              Center(child: Icon(Icons.more_horiz, color: Colors.grey, size: 48.0)),
            for (var i = 0; i < (4 - _customers.length); i++) Spacer(),
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
    _customerRepo = CustomerRepository(InheritedDatabase.of<DatabaseProvider>(context).provider);
    await _customerRepo.setUp();
    await onRefresh();
  }

  Future<void> onRefresh() async {
    _customers = await _customerRepo.select();
    setState(() => _customers);
  }
}
