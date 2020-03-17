import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../fonts/LiberationSans.dart';
import '../models/bill.dart';
import '../models/customer.dart';
import '../models/item.dart';

void main() {
  PdfGenerator pdf = PdfGenerator();
  Document doc;

  doc = pdf.createDocumentFromBill(
    Bill(
      id: 1,
      tax: 19,
      customer: Customer(
        id: 1,
        name: 'Leon',
        surname: 'Tappe',
        gender: Gender.diverse,
        email: 'ltappe@mail.upb.de',
        zipCode: 33098,
        city: 'Paderborn',
        address: 'Warburger Str. 100',
      ),
      items: [
        Item(id: 1, title: 'Papier A4', description: '100 Blatt', price: 100, quantity: 2, tax: 19),
        Item(id: 2, title: 'Bachelorarbeit', description: '', price: 2000, quantity: 1, tax: 19),
      ],
    ),
  );

  var file = File('./test.pdf');

  file.writeAsBytesSync(doc.save());

  print(doc);
}

class PdfGenerator {
  Font ttfSans;

  PdfGenerator() {
    final ByteData sansData = ByteData(liberationSans.length);
    for (int i = 0; i < liberationSans.length; i++) {
      sansData.setUint8(i, liberationSans[i]);
    }
    ttfSans = Font.ttf(sansData);
  }

  Document createDocumentFromBill(Bill bill) {
    final fontsize = 10.0;
    final Document doc = Document();
    final items = bill.items;

    doc.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.portrait,
        //crossAxisAlignment: CrossAxisAlignment.start,
        footer: _pageCountFooter,
        build: (Context context) => [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Paragraph(
                text: 'AStA Copyservice Warburger Str. 100 33098 Paderborn',
                style: TextStyle(
                    decoration: TextDecoration.underline, fontSize: fontsize, font: ttfSans),
                margin: EdgeInsets.only(bottom: 8.0),
              ),
              if (bill.customer.company != null)
                Paragraph(
                  text: bill.customer.company + ' ' + bill.customer.organizationUnit,
                  style: TextStyle(fontSize: fontsize),
                  margin: EdgeInsets.all(0.0),
                ),
              Paragraph(
                text: bill.customer.name + ' ' + bill.customer.surname,
                style: TextStyle(fontSize: fontsize),
                margin: EdgeInsets.all(0.0),
              ),
              Paragraph(
                text: bill.customer.address,
                style: TextStyle(fontSize: fontsize),
                margin: EdgeInsets.all(0.0),
              ),
              Paragraph(
                text: bill.customer.zipCode.toString() + ' ' + bill.customer.city,
                style: TextStyle(fontSize: fontsize),
                margin: EdgeInsets.all(0.0),
              ),
              if (bill.customer.country != null)
                Paragraph(
                  text: bill.customer.country,
                  style: TextStyle(fontSize: fontsize),
                  margin: EdgeInsets.only(bottom: 8.0),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 375.0, top: 16.0, bottom: 64.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Paragraph(
                  text: 'Kundennummer: ${bill.customer.id}',
                  style: TextStyle(fontSize: fontsize),
                  margin: EdgeInsets.all(0.0),
                ),
                Paragraph(
                  text: 'Bearbeiter*in:', //TODO
                  style: TextStyle(fontSize: fontsize),
                  margin: EdgeInsets.all(0.0),
                ),
                Paragraph(
                  text:
                      'Datum: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                  style: TextStyle(fontSize: fontsize),
                  margin: EdgeInsets.all(0.0),
                ),
              ],
            ),
          ),
          Header(level: 1, text: 'Rechnung Nr. ${bill.id}', textStyle: TextStyle(font: ttfSans)),
          Paragraph(text: 'Sehr geehrte Damen und Herren,', style: TextStyle(font: ttfSans)),
          Paragraph(
              text: 'hiermit berechnen wir Ihnen die folgenden Positionen:',
              style: TextStyle(font: ttfSans)),
          Table.fromTextArray(context: context, data: <List<String>>[
            <String>['Pos', 'Artikel', 'Menge', 'USt.', 'Einzelpreis EUR', 'Nettopreis EUR'],
            ...items.map(
              (e) => <String>[
                e.id.toString(),
                '${e.title} - ${e.description}',
                e.quantity.toString(),
                e.tax.toStringAsFixed(2),
                (e.price / 100.0).toStringAsFixed(2),
                (e.sum / 100.0).toStringAsFixed(2),
              ],
            )
          ]),
          Table.fromTextArray(context: context, data: <List<String>>[
            <String>['Gesamtbetrag', '${(bill.sum / 100.0).toStringAsFixed(2)} Euro'],
            <String>[
              'Davon Steuern',
              '${((bill.sum * (bill.tax / 100.0)) / 100.0).toStringAsFixed(2)} Euro'
            ]
          ]),
        ],
      ),
    );
    return doc;
  }

  List<int> getBytesFromBill(Bill bill) => createDocumentFromBill(bill).save();

  Widget _pageCountFooter(Context context) => Container(
      alignment: Alignment.centerRight,
      child: Text(context.pageNumber.toString(),
          style: Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey)));
}
