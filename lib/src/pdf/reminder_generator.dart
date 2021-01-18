import 'dart:typed_data';

import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../models/bill.dart';
import '../models/reminder.dart';
import '../models/vendor.dart';
import '../util.dart';
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
              text: (reminder.title != null && reminder.title.isNotEmpty)
                  ? reminder.title
                  : '${reminder.iteration == ReminderIteration.second ? 'Zweite ' : reminder.iteration == ReminderIteration.third ? 'Dritte ' : 'Erste '}Mahnung',
              textStyle: TextStyle(font: ttfSans)),
          Paragraph(text: 'Sehr geehrte Damen und Herren,', style: TextStyle(font: ttfSans)),
          Paragraph(text: reminder.text, style: TextStyle(font: ttfSans)),
          Table(
            columnWidths: <int, TableColumnWidth>{
              0: FixedColumnWidth(150.0),
              1: FixedColumnWidth(33.0),
              2: FixedColumnWidth(50.0),
            },
            tableWidth: TableWidth.max,
            border: TableBorder.ex(),
            children: <TableRow>[
              TableRow(children: <Widget>[
                PaddedHeaderText('Position'),
                PaddedHeaderText('Mahnstufe'),
                PaddedHeaderText('Betrag'),
              ]),
              TableRow(children: <Widget>[
                PaddedText('Rechnung ${bill.billNr} vom ${formatDate(bill.created)}', ttfSans),
                PaddedText('${reminder.iteration.index + 1}', ttfSans),
                PaddedText(formatFigure(bill.sum), ttfSans),
              ]),
              if (reminder.fee != 0)
                TableRow(children: <Widget>[
                  PaddedText('Mahngebühr', ttfSans),
                  PaddedText('', ttfSans),
                  PaddedText(formatFigure(reminder.fee), ttfSans),
                ]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Spacer(),
              Paragraph(
                text: 'Gesamtbetrag: ${formatFigure(bill.sum + (reminder.fee * 100))}',
                style: TextStyle(
                    fontSize: fontsize + 1.0, fontWeight: FontWeight.bold, font: ttfSansBold),
                margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
              ),
            ],
          ),
          Paragraph(
              text: 'Ursprünglich fällig am ${formatDate(bill.dueDate)}.',
              style: TextStyle(font: ttfSans)),
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
