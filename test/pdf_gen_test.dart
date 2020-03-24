import 'dart:io';

import 'package:bitter/src/bills/pdf_generator.dart';
import 'package:pdf/widgets.dart';

import 'example_data.dart';

void main() {
  final pdf = PdfGenerator();
  Document doc;

  final logo = File('logo.png');

  doc = pdf.createDocumentFromBill(exampleBill, exampleVendor, rightHeader: logo.readAsBytesSync());

  var file = File('./test.pdf');

  file.writeAsBytesSync(doc.save());

  print(doc);
}
