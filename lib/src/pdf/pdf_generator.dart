import 'dart:typed_data';

import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../models/customer.dart';
import '../models/draft.dart';
import '../models/item.dart';
import '../models/vendor.dart';
import '../util/format_util.dart';
import 'common_methods.dart';
import 'common_widgets.dart';

class PdfGenerator {
  Future<Document> createDocumentFromBill(
    Draft bill,
    Customer customer,
    Vendor vendor, {
    String billNr,
    Uint8List leftHeader,
    Uint8List centerHeader,
    Uint8List rightHeader,
    String title,
    String letter,
    bool showDates = true,
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

    bill.serviceDate ??= DateTime.now();

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
                if (customer.company != null)
                  Paragraph(
                    text: '${customer.company} ${customer.organizationUnit ?? ''}',
                    style: TextStyle(fontSize: fontsize),
                    margin: EdgeInsets.all(0.0),
                  ),
                Paragraph(
                  text: customer.name + ' ' + customer.surname,
                  style: TextStyle(fontSize: fontsize),
                  margin: EdgeInsets.all(0.0),
                ),
                Paragraph(
                  text: customer.address,
                  style: TextStyle(fontSize: fontsize),
                  margin: EdgeInsets.all(0.0),
                ),
                Paragraph(
                  text: customer.zipCode.toString() + ' ' + customer.city,
                  style: TextStyle(fontSize: fontsize),
                  margin: EdgeInsets.all(0.0),
                ),
                if (customer.country != null)
                  Paragraph(
                    text: customer.country,
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
                      text: 'Kundennummer: ${bill.customer}',
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
                    if (vendor.telephone != null)
                      Paragraph(
                        text: 'Telefon: ${vendor.telephone}',
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
            text: '${title == null || title.isEmpty ? 'Rechnung' : title} ${billNr ?? ''}',
            textStyle: TextStyle(font: ttfSans),
          ),
          Paragraph(text: 'Sehr geehrte Damen und Herren,', style: TextStyle(font: ttfSans)),
          Paragraph(
            text: letter == null || letter.isEmpty
                ? 'hiermit berechnen wir Ihnen die folgenden Positionen:'
                : letter,
            style: TextStyle(font: ttfSans),
          ),
          Table(
            columnWidths: <int, TableColumnWidth>{
              0: FixedColumnWidth(22.0),
              1: FixedColumnWidth(150.0),
              2: FixedColumnWidth(32.0),
              3: FixedColumnWidth(!vendor.smallBusiness ? 24.0 : 74.0),
              4: FixedColumnWidth(!vendor.smallBusiness ? 50.0 : 55.0),
              5: FixedColumnWidth(55.0),
            },
            tableWidth: TableWidth.max,
            border: TableBorder.all(),
            children: <TableRow>[
              TableRow(children: <Widget>[
                PaddedHeaderText('Pos.'),
                PaddedHeaderText('Artikel'),
                PaddedHeaderText('Menge'),
                if (!vendor.smallBusiness) PaddedHeaderText('USt.'),
                PaddedHeaderText('Einzelpreis\nBrutto'),
                PaddedHeaderText('Gesamtpreis\nBrutto')
              ]),
              ...items.map((Item i) => TableRow(children: <Widget>[
                    PaddedText(i.uid, ttfSans),
                    PaddedText(
                        (i.description != null) ? '${i.title} - ${i.description}' : '${i.title}',
                        ttfSans),
                    PaddedText(i.quantity.toString(), ttfSans),
                    if (!vendor.smallBusiness) PaddedText('${i.tax.toStringAsFixed(0)} %', ttfSans),
                    PaddedText(formatFigure(i.price), ttfSans),
                    PaddedText(formatFigure(i.sum), ttfSans),
                  ])),
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
                    text: 'Gesamtbetrag: ${formatFigure(bill.sum)}',
                    style: TextStyle(
                        fontSize: fontsize + 1.0, fontWeight: FontWeight.bold, font: ttfSansBold),
                    margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  ),
                  if (!vendor.smallBusiness)
                    Paragraph(
                      text:
                          'Der Gesamtbetrag setzt sich aus ${formatFigure(bill.sum - calculateTaxes(bill.items, bill.tax))} netto zzgl. ${formatFigure(calculateTaxes(bill.items, bill.tax))} Umsatzsteuer zusammen.',
                      style: TextStyle(fontSize: fontsize + 1.0, font: ttfSans),
                      margin: EdgeInsets.all(0.0),
                    )
                  else
                    Paragraph(
                      text:
                          'Als Kleinunternehmer im Sinne von § 19 Abs. 1 UStG wird keine Umsatzsteuer berechnet.',
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
            style: TextStyle(font: ttfSans),
          ),
          Paragraph(text: bill.comment ?? '', style: TextStyle(font: ttfSans)),
          if (showDates)
            Paragraph(
              text: 'Lieferdatum/Leistungsdatum: ${formatDate(bill.serviceDate)}',
              style: TextStyle(font: ttfSans),
            ),
          if (showDates)
            Paragraph(
              text:
                  'Bezahlbar ohne Abzug bis zum ${formatDate(DateTime.now().add(Duration(days: bill.dueDays)))}.',
              style: TextStyle(font: ttfSans),
            ),
        ],
      ),
    );
    return doc;
  }

  Future<List<int>> getBytesFromBill(
    Draft bill,
    Customer customer,
    Vendor vendor, {
    String billNr,
    Uint8List leftHeader,
    Uint8List centerHeader,
    Uint8List rightHeader,
    String title,
    String letter,
    bool showDates = true,
  }) async =>
      (await createDocumentFromBill(
        bill,
        customer,
        vendor,
        billNr: billNr,
        leftHeader: leftHeader,
        centerHeader: centerHeader,
        rightHeader: rightHeader,
        title: title,
        letter: letter,
        showDates: showDates,
      ))
          .save();
}
