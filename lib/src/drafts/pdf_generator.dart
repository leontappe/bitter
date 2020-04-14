import 'dart:typed_data';

import 'package:image/image.dart' as im;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../fonts/LiberationSans.dart';
import '../models/customer.dart';
import '../models/draft.dart';
import '../models/vendor.dart';

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
      items[i].id = '${i + 1}';
    }

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
          Padding(
            padding: EdgeInsets.only(left: 375.0, top: 16.0, bottom: 64.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Paragraph(
                  text: 'Kundennummer: ${bill.customer}',
                  style: TextStyle(fontSize: fontsize),
                  margin: EdgeInsets.all(0.0),
                ),
                Paragraph(
                  text: 'Bearbeiter*in: ${bill.editor}',
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
          Header(level: 1, text: 'Rechnung ${billNr}', textStyle: TextStyle(font: ttfSans)),
          Paragraph(text: 'Sehr geehrte Damen und Herren,', style: TextStyle(font: ttfSans)),
          Paragraph(
              text: 'hiermit berechnen wir Ihnen die folgenden Positionen:',
              style: TextStyle(font: ttfSans)),
          Table.fromTextArray(context: context, data: <List<String>>[
            <String>['Pos', 'Artikel', 'Menge', 'USt.', 'Einzelpreis EUR', 'Nettopreis EUR'],
            ...items.map(
              (e) => <String>[
                e.id.toString(),
                (e.description != null) ? '${e.title} - ${e.description}' : '${e.title}',
                e.quantity.toString(),
                (e.tax == 0) ? bill.tax.toStringAsFixed(2) : e.tax.toStringAsFixed(2),
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

  Widget _createHeaderFromImages(PdfDocument doc,
      {Uint8List left, Uint8List center, Uint8List right}) {
    im.Image leftImg;
    im.Image rightImg;
    im.Image centerImg;

    if (left != null) {
      leftImg = im.decodeImage(left);
    }
    if (right != null) {
      rightImg = im.decodeImage(right);
    }
    if (center != null) {
      centerImg = im.decodeImage(center);
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Paragraph(
                  text: 'Geschäftsinhaber:',
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color),
                  margin: EdgeInsets.only(bottom: 8.0)),
              Text(vendor.name, style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
              Text(vendor.address,
                  style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
              Text(vendor.city, style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
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
              Text(vendor.bank, style: TextStyle(fontSize: fontSize, font: ttfSans, color: color)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
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
