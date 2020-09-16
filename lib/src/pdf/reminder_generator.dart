import 'dart:typed_data';

import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../models/bill.dart';
import '../models/item.dart';
import '../models/reminder.dart';
import '../models/vendor.dart';
import 'common_methods.dart';
import 'common_widgets.dart';

class ReminderGenerator {
  Future<Document> createDocumentFromBill(
    Bill bill,
    Vendor vendor,
    Reminder reminder, {
    Uint8List leftHeader,
    Uint8List centerHeader,
    Uint8List rightHeader,
  }) async {
    await initializeDateFormatting('de_DE');

    final ttfSans = getTtfSans();
    final ttfSansBold = getTtfSansBold();

    final fontsize = 10.0;
    final doc = Document();
    final items = bill.items;

    for (var i = 0; i < items.length; i++) {
      items[i].uid = '${i + 1}';
    }

    doc.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.portrait,
        header: (Context context) => createHeaderFromImages(doc.document,
            left: leftHeader, center: centerHeader, right: rightHeader),
        footer: (Context context) => pageCountFooter(context, vendor, ttfSans),
        build: (Context context) => [
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Paragraph(
                  text: vendor.fullAddress,
                  style: TextStyle(
                      decoration: TextDecoration.underline, fontSize: fontsize, font: ttfSans),
                  margin: EdgeInsets.only(bottom: 8.0),
                ),
                if (bill.customer.company != null)
                  Paragraph(
                    text: '${bill.customer.company} ${bill.customer.organizationUnit ?? ''}',
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Spacer(),
              Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 60.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Paragraph(
                      text: 'Kundennummer: ${bill.customer.id}',
                      style: TextStyle(fontSize: fontsize),
                      margin: EdgeInsets.all(0.0),
                    ),
                    if (vendor.contact != null && vendor.contact.isNotEmpty)
                      Paragraph(
                        text: 'Ansprechpartner*in: ${vendor.contact}',
                        style: TextStyle(fontSize: fontsize),
                        margin: EdgeInsets.all(0.0),
                      ),
                    Paragraph(
                      text: 'E-Mail: ${vendor.email}',
                      style: TextStyle(fontSize: fontsize),
                      margin: EdgeInsets.all(0.0),
                    ),
                    Paragraph(
                      text: 'Datum: ${formatDate(DateTime.now())}',
                      style: TextStyle(fontSize: fontsize),
                      margin: EdgeInsets.all(0.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Header(
              level: 1,
              text:
                  '${reminder.iteration == ReminderIteration.second ? 'Zweite ' : reminder.iteration == ReminderIteration.third ? 'Dritte ' : ''}Mahnung für ${bill.billNr}',
              textStyle: TextStyle(font: ttfSans)),
          Paragraph(text: 'Sehr geehrte Damen und Herren,', style: TextStyle(font: ttfSans)),
          Paragraph(text: reminder.text, style: TextStyle(font: ttfSans)),
          Table(
            columnWidths: <int, TableColumnWidth>{
              0: FixedColumnWidth(22.0),
              1: FixedColumnWidth(150.0),
              2: FixedColumnWidth(32.0),
              3: FixedColumnWidth(24.0),
              4: FixedColumnWidth(50.0),
              5: FixedColumnWidth(55.0),
            },
            tableWidth: TableWidth.max,
            border: TableBorder(),
            children: <TableRow>[
              TableRow(children: <Widget>[
                PaddedHeaderText('Pos.'),
                PaddedHeaderText('Artikel'),
                PaddedHeaderText('Menge'),
                PaddedHeaderText('USt.'),
                PaddedHeaderText('Einzelpreis\nBrutto'),
                PaddedHeaderText('Gesamtpreis\nBrutto')
              ]),
              ...items.map((Item i) => TableRow(children: <Widget>[
                    PaddedText(i.uid, ttfSans),
                    PaddedText(
                        (i.description != null) ? '${i.title} - ${i.description}' : '${i.title}',
                        ttfSans),
                    PaddedText(i.quantity.toString(), ttfSans),
                    PaddedText('${i.tax.toStringAsFixed(0)} %', ttfSans),
                    PaddedText(
                        (i.price / 100.0).toStringAsFixed(2).replaceAll('.', ',') + ' €', ttfSans),
                    PaddedText(
                        (i.sum / 100.0).toStringAsFixed(2).replaceAll('.', ',') + ' €', ttfSans),
                  ])),
              if (reminder.fee != 0)
                TableRow(children: <Widget>[
                  PaddedText('${items.length + 1}', ttfSans),
                  PaddedText('Mahngebühr', ttfSans),
                  PaddedText('1', ttfSans),
                  PaddedText('0%', ttfSans),
                  PaddedText(reminder.fee.toStringAsFixed(2).replaceAll('.', ',') + ' €', ttfSans),
                  PaddedText(reminder.fee.toStringAsFixed(2).replaceAll('.', ',') + ' €', ttfSans),
                ]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Paragraph(
                    text:
                        'Gesamtbetrag: ${((bill.sum / 100.0) + reminder.fee).toStringAsFixed(2).replaceAll('.', ',')} €',
                    style: TextStyle(
                        fontSize: fontsize + 1.0, fontWeight: FontWeight.bold, font: ttfSansBold),
                    margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  ),
                  Paragraph(
                    text:
                        'Der Gesamtbetrag setzt sich aus ${(((bill.sum - calculateTaxes(bill.items, vendor.defaultTax)) / 100.0) + reminder.fee).toStringAsFixed(2).replaceAll('.', ',')} € netto zzgl. ${(calculateTaxes(bill.items, vendor.defaultTax) / 100.0).toStringAsFixed(2).replaceAll('.', ',')} € Umsatzsteuer zusammen.',
                    style: TextStyle(fontSize: fontsize + 1.0, font: ttfSans),
                    margin: EdgeInsets.all(0.0),
                  ),
                ],
              ),
            ],
          ),
          Paragraph(
              text: ((vendor.userMessageLabel != null && bill.userMessage != null)
                      ? '${vendor.userMessageLabel}: '
                      : '') +
                  (bill.userMessage ?? ''),
              style: TextStyle(font: ttfSans)),
          Paragraph(text: bill.comment ?? '', style: TextStyle(font: ttfSans)),
          Paragraph(
              text: 'Zahlbar bis ${formatDate(reminder.deadline)}.',
              style: TextStyle(font: ttfSans)),
        ],
      ),
    );
    return doc;
  }

  Future<List<int>> getBytesFromBill(
    Bill bill,
    Vendor vendor,
    Reminder reminder, {
    Uint8List leftHeader,
    Uint8List centerHeader,
    Uint8List rightHeader,
  }) async =>
      (await createDocumentFromBill(
        bill,
        vendor,
        reminder,
        leftHeader: leftHeader,
        centerHeader: centerHeader,
        rightHeader: rightHeader,
      ))
          .save();
}
