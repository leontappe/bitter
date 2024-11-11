import 'package:flutter/material.dart';

import '/src/models/customer.dart';
import '/src/pages/customers/customer_page.dart';
import 'base_shortcut.dart';

class CustomerShortcut extends StatelessWidget {
  final BuildContext context;
  final Customer customer;

  const CustomerShortcut(this.context, {super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BaseShortcut(
      context,
      onTap: () => Navigator.push<bool>(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  CustomerPage(id: customer.id))),
      children: <Widget>[
        Text(customer.fullCompany ?? customer.fullName,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
            textScaleFactor: 1.1,
            overflow: TextOverflow.ellipsis),
        Text('${customer.address} ${customer.zipCode} ${customer.city}',
            overflow: TextOverflow.ellipsis),
        Text(customer.email, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
