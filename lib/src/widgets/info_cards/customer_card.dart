import 'package:flutter/material.dart';

import '../../models/customer.dart';
import '../attribute_table.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({Key key, this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      elevation: 8.0,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.company != null && customer.company.isNotEmpty)
              Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(customer.company, style: Theme.of(context).textTheme.headline6))
            else
              Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(customer.name + ' ' + customer.surname,
                      style: Theme.of(context).textTheme.headline6)),
            AttributeTable(
              attributes: <String, String>{
                if (customer.company != null && customer.company.isNotEmpty)
                  customer.gender == Gender.male
                      ? 'Ansprechpartner'
                      : customer.gender == Gender.female
                          ? 'Ansprechpartnerin'
                          : 'Ansprechpartner*in': customer.name + ' ' + customer.surname,
                if (customer.organizationUnit != null && customer.organizationUnit.isNotEmpty)
                  'Abteilung': customer.organizationUnit,
                'Adresse': customer.address,
                'Stadt': '${customer.zipCode} ${customer.city}',
                if (customer.country != null) 'Land': customer.country,
                'E-Mail': customer.email,
                if (customer.telephone != null) 'Telefon': customer.telephone,
                if (customer.fax != null) 'Fax': customer.fax,
                if (customer.mobile != null) 'Mobil': customer.mobile,
              },
            ),
          ],
        ),
      ),
    );
  }
}
