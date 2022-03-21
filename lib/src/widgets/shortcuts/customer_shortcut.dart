import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../../pages/customers/customer_page.dart';
import 'base_shortcut.dart';

class CustomerShortcut extends StatelessWidget {
  final BuildContext context;
  final Customer customer;

  const CustomerShortcut(this.context, {Key key, @required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseShortcut(
      context,
      onTap: () => Navigator.push<bool>(context,
          MaterialPageRoute(builder: (BuildContext context) => CustomerPage(id: customer.id))),
      children: <Widget>[
        Text(customer.fullCompany ?? customer.fullName,
            style: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
            textScaleFactor: 1.1,
            overflow: TextOverflow.ellipsis),
        Text('${customer.address} ${customer.zipCode} ${customer.city}',
            overflow: TextOverflow.ellipsis),
        Text(customer.email, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
