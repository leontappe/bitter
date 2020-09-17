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
            if (vendor.manager != null) Text('Organisation: ${vendor.manager}'),
            if (vendor.contact != null) Text('Ansprechpartner: ${vendor.contact}'),
            Text('Adresse: ${vendor.address}'),
            Text('Postleitzahl: ${vendor.zipCode}'),
            Text('Stadt: ${vendor.city}'),
            Text('IBAN: ${vendor.iban}'),
            Text('BIC: ${vendor.bic}'),
            Text('Bank: ${vendor.bank}'),
            Text('Steuernummer: ${vendor.taxNr}'),
            Text('Umsatzsteuernummer: ${vendor.vatNr}'),
            Text('E-Mail: ${vendor.email}'),
            if (vendor.website != null) Text('Website: ${vendor.website}'),
            Text('Adresszeile für Briefkopf: ${vendor.fullAddress}'),
            Text('Prefix für Rechnungsnummern: ${vendor.billPrefix}'),
            Text('Standard Zahlungsfrist: ${vendor.defaultDueDays} Tage'),
            Text('Standard Umsatzsteuer: ${vendor.defaultTax} %'),
            if (vendor.defaultComment != null)
              Text('Standard Rechnungskommentar: ${vendor.defaultComment}'),
            if (vendor.reminderFee != null) Text('Standard Mahngebühr: ${vendor.reminderFee}€'),
            if (vendor.reminderDeadline != null)
              Text('Standardfrist für Mahnungen: ${vendor.reminderDeadline} Tage'),
            if (vendor.reminderTitles != null)
              ...vendor.reminderTitles
                  .map((key, value) => (value.isNotEmpty)
                      ? MapEntry(key, Text('Titel für ${key.index + 1}. Mahnung: $value'))
                      : MapEntry(key, Container(width: 0, height: 0)))
                  .values,
            if (vendor.reminderTexts != null)
              ...vendor.reminderTexts
                  .map((key, value) => (value.isNotEmpty)
                      ? MapEntry(key, Text('Text für ${key.index + 1}. Mahnung: $value'))
                      : MapEntry(key, Container(width: 0, height: 0)))
                  .values,
            Text(
                'Kopfzeilenbilder:\n\tRechts: ${vendor.headerImageRight != null ? 'Vorhanden' : 'Nicht vorhanden'}\n\tMitte: ${vendor.headerImageCenter != null ? 'Vorhanden' : 'Nicht vorhanden'}\n\tLinks: ${vendor.headerImageLeft != null ? 'Vorhanden' : 'Nicht vorhanden'}'),
            Text(
                'Label für benutzerdefinierten Rechnungskommentar: ${vendor.userMessageLabel ?? 'Keins'}'),
          ],
        ),
      ),
    );
  }
}
