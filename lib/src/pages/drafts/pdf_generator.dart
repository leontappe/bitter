import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../fonts/LiberationSans.dart';
import '../../models/customer.dart';
import '../../models/draft.dart';
import '../../models/item.dart';
import '../../models/vendor.dart';

class PaddedHeaderText extends Padding {
  PaddedHeaderText(String text)
      : super(
            padding: EdgeInsets.all(4.0),
            child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)));
}

class PaddedText extends Padding {
  PaddedText(String text, Font font)
      : super(padding: EdgeInsets.all(2.0), child: Text(text, style: TextStyle(font: font)));
}

class PdfGenerator {
  Font ttfSans;

  Document createDocumentFromBill(String billNr, Draft bill, Customer customer, Vendor vendor,
      {Uint8List leftHeader, Uint8List centerHeader, Uint8List rightHeader}) {
    final sansData = ByteData(liberationSans.length);
    for (var i = 0; i < liberationSans.length; i++) {
      sansData.setUint8(i, liberationSans[i]);
    }
    ttfSans = Font.ttf(sansData);

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
        //crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) => _createHeaderFromImages(doc.document,
            left: leftHeader, center: centerHeader, right: rightHeader),
        footer: (Context context) => _pageCountFooter(context, vendor),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Paragraph(
                      text: 'Kundennummer: ${bill.customer}',
                      style: TextStyle(fontSize: fontsize),
                      margin: EdgeInsets.all(0.0),
                    ),
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
                      text:
                          'Datum: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                      style: TextStyle(fontSize: fontsize),
                      margin: EdgeInsets.all(0.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Header(level: 1, text: 'Rechnung ${billNr}', textStyle: TextStyle(font: ttfSans)),
          Paragraph(text: 'Sehr geehrte Damen und Herren,', style: TextStyle(font: ttfSans)),
          Paragraph(
              text: 'hiermit berechnen wir Ihnen die folgenden Positionen:',
              style: TextStyle(font: ttfSans)),
          Table(
            columnWidths: <int, TableColumnWidth>{
              0: FixedColumnWidth(20.0),
              2: FixedColumnWidth(32.0),
              3: FixedColumnWidth(24.0),
              4: FixedColumnWidth(50.0),
              5: FixedColumnWidth(50.0),
            },
            tableWidth: TableWidth.max,
            border: TableBorder(),
            children: <TableRow>[
              TableRow(children: <Widget>[
                PaddedHeaderText('Pos.'),
                PaddedHeaderText('Artikel'),
                PaddedHeaderText('Menge'),
                PaddedHeaderText('Ust.'),
                PaddedHeaderText('Einzelpreis'),
                PaddedHeaderText('Bruttopreis')
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
                        'Gesamtbetrag: ${(bill.sum / 100.0).toStringAsFixed(2).replaceAll('.', ',')} EUR',
                    style: TextStyle(fontSize: fontsize, fontWeight: FontWeight.bold),
                    margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  ),
                  Paragraph(
                    text:
                        'Davon Umsatzsteuer: ${_calculateTaxes(bill.items, bill.tax).toStringAsFixed(2).replaceAll('.', ',')} EUR',
                    style: TextStyle(fontSize: fontsize),
                    margin: EdgeInsets.all(0.0),
                  )
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
          Paragraph(
              text:
                  'Lieferdatum/Leistungsdatum: ${bill.serviceDate.day}.${bill.serviceDate.month}.${bill.serviceDate.year}',
              style: TextStyle(font: ttfSans)),
          Paragraph(
              text:
                  'Bezahlbar ohne Abzug bis: ${bill.serviceDate.add(Duration(days: bill.dueDays)).day}.${bill.serviceDate.add(Duration(days: bill.dueDays)).month}.${bill.serviceDate.add(Duration(days: bill.dueDays)).year}',
              style: TextStyle(font: ttfSans)),
        ],
      ),
    );
    return doc;
  }

  List<int> getBytesFromBill(
    String billNr,
    Draft bill,
    Customer customer,
    Vendor vendor, {
    Uint8List leftHeader,
    Uint8List centerHeader,
    Uint8List rightHeader,
  }) =>
      createDocumentFromBill(
        billNr,
        bill,
        customer,
        vendor,
        leftHeader: leftHeader,
        centerHeader: centerHeader,
        rightHeader: rightHeader,
      ).save();

  double _calculateTaxes(List<Item> items, int tax) {
    var tax = 0.0;
    for (var item in items) {
      tax += ((item.price * item.quantity) * ((item.tax ?? tax) / 100.0));
    }
    return tax.round() / 100.0;
  }

  Widget _createHeaderFromImages(PdfDocument doc,
      {Uint8List left, Uint8List center, Uint8List right}) {
    img.Image leftImg;
    img.Image rightImg;
    img.Image centerImg;

    if (left != null) {
      leftImg = img.decodeImage(left);
    }
    if (right != null) {
      rightImg = img.decodeImage(right);
    }
    if (center != null) {
      centerImg = img.decodeImage(center);
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (left != null)
          Container(
            height: 48.0,
            child: Image(
              PdfImage(doc,
                  image: leftImg.data.buffer.asUint8List(),
                  height: leftImg.height,
                  width: leftImg.width),
            ),
          )
        else
          Container(width: 0.0, height: 0.0),
        if (center != null)
          Container(
            height: 48.0,
            child: Image(
              PdfImage(doc,
                  image: centerImg.data.buffer.asUint8List(),
                  height: centerImg.height,
                  width: centerImg.width),
            ),
          )
        else
          Container(width: 0.0, height: 0.0),
        if (right != null)
          Container(
            height: 48.0,
            child: Image(
              PdfImage(doc,
                  image: rightImg.data.buffer.asUint8List(),
                  height: rightImg.height,
                  width: rightImg.width),
            ),
          )
        else
          Container(width: 0.0, height: 0.0),
      ],
    );
  }

  Widget _pageCountFooter(Context context, Vendor vendor) {
    final fontSize = 9.0;
    final color = PdfColors.grey800;
    return Column(children: <Widget>[
      Container(
          margin: EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
              border: BoxBorder(
                  top: true,
                  bottom: false,
                  right: false,
                  left: false,
                  color: PdfColors.grey400,
                  width: 1.0),
              borderRadius: 0.0,
              shape: BoxShape.rectangle),
          child: Container(width: 500.0, height: 0.0)),
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Paragraph(
                  text: 'Geschäftsinhaber:',
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color),
                  margin: EdgeInsets.only(bottom: 8.0)),
              if (vendor.manager == null || vendor.manager.isEmpty)
                Text(vendor.name, style: TextStyle(fontSize: fontSize, font: ttfSans, color: color))
              else
                Text(vendor.manager,
                    style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
              Text(vendor.address,
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
              Text('${vendor.zipCode} ${vendor.city}',
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Paragraph(
                  text: 'Bankverbindung:',
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color),
                  margin: EdgeInsets.only(bottom: 8.0)),
              Text('IBAN: ${vendor.iban}',
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
              Text('BIC: ${vendor.bic}',
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
              Text('Bank: ${vendor.bank}',
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Paragraph(
                  text: 'Steuer-Nr.: ${vendor.taxNr}',
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color),
                  margin: EdgeInsets.only(top: 17.0)),
              Text('USt.-Ident.-Nr.: ${vendor.vatNr}',
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
              Text(vendor.website ?? '',
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
            ],
          ),
        ],
      ),
    ]);
  }
}
