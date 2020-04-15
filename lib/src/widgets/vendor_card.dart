import 'package:flutter/material.dart';

import '../models/vendor.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;

  const VendorCard({Key key, this.vendor}) : super(key: key);

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
            Text(vendor.name, style: Theme.of(context).textTheme.headline5),
            Text('Adresse: ${vendor.address}'),
            Text('Stadt: ${vendor.city}'),
            Text('IBAN: ${vendor.iban}'),
            Text('BIC: ${vendor.bic}'),
            Text('Bank: ${vendor.bank}'),
            Text('Steuernummer: ${vendor.taxNr}'),
            Text('Umsatzsteuernummer: ${vendor.vatNr}'),
            if (vendor.website != null) Text('Website: ${vendor.website}'),
            Text('Adresszeile für Briefkopf: ${vendor.fullAddress}'),
            Text('Prefix für Rechnungsnummern: ${vendor.billPrefix}'),
            Text('Kopfzeilenbild: ${vendor.headerImage != null ? 'Vorhanden' : 'Nicht vorhanden'}'),
          ],
        ),
      ),
    );
  }
}
