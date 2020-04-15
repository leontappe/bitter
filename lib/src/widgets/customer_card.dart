import 'package:flutter/material.dart';

import '../models/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({Key key, this.customer}) : super(key: key);

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
            if (customer.company != null && customer.company.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(customer.company, style: Theme.of(context).textTheme.headline5),
                  Text('Ansprechpartner: ' + customer.name + ' ' + customer.surname)
                ],
              )
            else
              Text(customer.name + ' ' + customer.surname,
                  style: Theme.of(context).textTheme.headline5),
            if (customer.organizationUnit != null && customer.organizationUnit.isNotEmpty)
              Text('Abteilung: ${customer.organizationUnit}'),
            Text('Adresse: ${customer.address}'),
            Text('Stadt: ${customer.zipCode} ${customer.city}'),
            if (customer.country != null) Text('Land: ${customer.country}'),
            if (customer.telephone != null) Text('Telefon: ${customer.telephone}'),
            if (customer.fax != null) Text('Fax: ${customer.fax}'),
            if (customer.mobile != null) Text('Mobil: ${customer.mobile}'),
            Text('E-Mail: ${customer.email}')
          ],
        ),
      ),
    );
  }
}
