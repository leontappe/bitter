import 'package:flutter/material.dart';

import '../../models/reminder.dart';
import '../../models/vendor.dart';
import '../../util/format_util.dart';
import '../attribute_table.dart';

class VendorCard extends StatelessWidget {
  final Vendor vendor;

  const VendorCard({Key key, this.vendor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(vendor.name, style: Theme.of(context).textTheme.headline6),
            ),
            AttributeTable(
              attributes: <String, String>{
                if (vendor.manager != null) 'Organisation': vendor.manager,
                if (vendor.contact != null) 'Ansprechpartner*in': vendor.contact,
                'Adresse': vendor.address,
                'Postleitzahl': vendor.zipCode.toString(),
                'Stadt': vendor.city,
                'IBAN': vendor.iban,
                'BIC': vendor.bic,
                'Bank': vendor.bank,
                'Steuernummer': vendor.taxNr,
                'Umsatzsteuernummer': vendor.vatNr,
                'E-Mail': vendor.email,
                if (vendor.website != null) 'Website': vendor.website,
                if (vendor.telephone != null) 'Telefon': vendor.telephone,
                'Adresszeile für Briefkopf': vendor.fullAddress,
                'Prefix für Rechnungsnummern': vendor.billPrefix,
                'Standard Zahlungsfrist': '${vendor.defaultDueDays} Tage',
                'Standard Umsatzsteuer': '${vendor.defaultTax} %',
                if (vendor.defaultComment != null)
                  'Standard Rechnungskommentar': vendor.defaultComment,
                if (vendor.reminderFees[ReminderIteration.first] != null)
                  'Standard Mahngebühr für erste Mahnung':
                      formatFigure(vendor.reminderFees[ReminderIteration.first]),
                if (vendor.reminderFees[ReminderIteration.second] != null)
                  'Standard Mahngebühr für zweite Mahnung':
                      formatFigure(vendor.reminderFees[ReminderIteration.second]),
                if (vendor.reminderFees[ReminderIteration.third] != null)
                  'Standard Mahngebühr für dritte Mahnung':
                      formatFigure(vendor.reminderFees[ReminderIteration.third]),
                if (vendor.reminderDeadline != null)
                  'Standardfrist für Mahnungen': '${vendor.reminderDeadline} Tage',
                if (vendor.reminderTitles != null)
                  ...vendor.reminderTitles.map(
                      (key, value) => MapEntry('Titel für ${key.index + 1}. Mahnung', value ?? '')),
                if (vendor.reminderTexts != null)
                  ...vendor.reminderTexts.map(
                      (key, value) => MapEntry('Text für ${key.index + 1}. Mahnung', value ?? '')),
                if (vendor.headerImageLeft != null) 'Linkes Kopfzeilenbild': 'Vorhanden',
                if (vendor.headerImageCenter != null) 'Mittleres Kopfzeilenbild': 'Vorhanden',
                if (vendor.headerImageRight != null) 'Rechtes Kopfzeilenbild': 'Vorhanden',
                'Label für benutzerdefinierten Rechnungskommentar':
                    vendor.userMessageLabel ?? 'Keins',
                'Kleingewerberegelung': vendor.smallBusiness ? 'Ja' : 'Nein',
                'Freitext für Fußzeile': vendor.freeInformation ?? '',
              },
            ),
          ],
        ),
      ),
    );
  }
}
