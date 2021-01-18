import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../models/vendor.dart';

Widget createHeaderFromImages(PdfDocument doc,
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

  return Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (left != null)
            Container(
              height: 48.0,
              child: Image.provider(
                RawImage(
                  bytes: leftImg.data.buffer.asUint8List(),
                  height: leftImg.height,
                  width: leftImg.width,
                ),
              ),
            )
          else
            Container(width: 0.0, height: 0.0),
          if (center != null)
            Container(
              height: 48.0,
              child: Image.provider(
                RawImage(
                  bytes: centerImg.data.buffer.asUint8List(),
                  height: centerImg.height,
                  width: centerImg.width,
                ),
              ),
            )
          else
            Container(width: 0.0, height: 0.0),
          if (right != null)
            Container(
              height: 48.0,
              child: Image.provider(
                RawImage(
                  bytes: rightImg.data.buffer.asUint8List(),
                  height: rightImg.height,
                  width: rightImg.width,
                ),
              ),
            )
          else
            Container(width: 0.0, height: 0.0),
        ],
      ));
}

Widget pageCountFooter(Context context, Vendor vendor, Font font) {
  final fontSize = 9.0;
  final color = PdfColors.grey800;
  return Column(children: <Widget>[
    Container(
        margin: EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: PdfColors.grey400,
              width: 1.0,
            ),
          ),
          borderRadiusEx: BorderRadius.all(Radius.zero),
          shape: BoxShape.rectangle,
        ),
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
                style: TextStyle(fontSize: fontSize, font: font, color: color),
                margin: EdgeInsets.only(bottom: 8.0)),
            if (vendor.manager == null || vendor.manager.isEmpty)
              Text(vendor.name, style: TextStyle(fontSize: fontSize, font: font, color: color))
            else
              Text(vendor.manager, style: TextStyle(fontSize: fontSize, font: font, color: color)),
            Text(vendor.address, style: TextStyle(fontSize: fontSize, font: font, color: color)),
            Text('${vendor.zipCode} ${vendor.city}',
                style: TextStyle(fontSize: fontSize, font: font, color: color)),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Paragraph(
                text: 'Bankverbindung:',
                style: TextStyle(fontSize: fontSize, font: font, color: color),
                margin: EdgeInsets.only(bottom: 8.0)),
            Text('IBAN: ${vendor.iban}',
                style: TextStyle(fontSize: fontSize, font: font, color: color)),
            Text('BIC: ${vendor.bic}',
                style: TextStyle(fontSize: fontSize, font: font, color: color)),
            Text('Bank: ${vendor.bank}',
                style: TextStyle(fontSize: fontSize, font: font, color: color)),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Paragraph(
                text: 'Steuer-Nr.: ${vendor.taxNr}',
                style: TextStyle(fontSize: fontSize, font: font, color: color),
                margin: EdgeInsets.only(top: 17.0)),
            Text('USt.-ID: ${vendor.vatNr}',
                style: TextStyle(fontSize: fontSize, font: font, color: color)),
            Text(vendor.website ?? '',
                style: TextStyle(fontSize: fontSize, font: font, color: color)),
          ],
        ),
      ],
    ),
  ]);
}

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
