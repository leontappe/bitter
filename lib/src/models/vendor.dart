import 'dart:convert';

import 'package:meta/meta.dart';

enum HeaderImage {
  right,
  center,
  left,
}

class Vendor {
  int id;
  String name;
  String contact;
  String address;
  int zipCode;
  String city;
  String iban;
  String bic;
  String bank;
  String taxNr;
  String vatNr;
  String website;

  String fullAddress;
  String billPrefix;

  int defaultDueDays;
  int defaultTax;

  List<int> headerImageRight;
  List<int> headerImageCenter;
  List<int> headerImageLeft;

  String userMessageLabel;

  Vendor({
    this.id,
    @required this.name,
    @required this.contact,
    @required this.address,
    @required this.zipCode,
    @required this.city,
    @required this.iban,
    @required this.bic,
    @required this.bank,
    this.taxNr,
    this.vatNr,
    this.website,
    @required this.fullAddress,
    @required this.billPrefix,
    this.defaultDueDays,
    this.defaultTax,
    this.headerImageRight,
    this.headerImageCenter,
    this.headerImageLeft,
    this.userMessageLabel,
  });

  factory Vendor.empty() => Vendor(
        name: null,
        contact: null,
        address: null,
        zipCode: null,
        city: null,
        iban: null,
        bic: null,
        bank: null,
        fullAddress: null,
        billPrefix: null,
        defaultDueDays: 14,
        defaultTax: 19,
      );

  factory Vendor.fromMap(Map map) => Vendor(
        id: map['id'] as int,
        name: map['name'].toString(),
        contact: map['contact'].toString(),
        address: map['address'].toString(),
        zipCode: int.parse(map['zip_code'].toString()),
        city: map['city'].toString(),
        iban: map['iban'].toString(),
        bic: map['bic'].toString(),
        bank: map['bank'].toString(),
        taxNr: map['tax_nr'].toString(),
        vatNr: map['vat_nr'].toString(),
        website: (map['website'] != null) ? map['website'].toString() : null,
        fullAddress: map['full_address'].toString(),
        billPrefix: map['bill_prefix'].toString(),
        defaultDueDays: map['default_due_days'] as int,
        defaultTax: map['default_tax'] as int,
        headerImageRight: (map['header_image_right'] != null)
            ? base64.decode(map['header_image_right'].toString())
            : null,
        headerImageCenter: (map['header_image_center'] != null)
            ? base64.decode(map['header_image_center'].toString())
            : null,
        headerImageLeft: (map['header_image_left'] != null)
            ? base64.decode(map['header_image_left'].toString())
            : null,
        userMessageLabel:
            (map['user_message_label'] != null) ? map['user_message_label'].toString() : null,
      );

  @override
  int get hashCode => name.hashCode;

  Map<String, dynamic> get toMap => <String, dynamic>{
        ...toMapShort,
        'header_image_right': (headerImageRight != null) ? base64.encode(headerImageRight) : null,
        'header_image_center':
            (headerImageCenter != null) ? base64.encode(headerImageCenter) : null,
        'header_image_left': (headerImageLeft != null) ? base64.encode(headerImageLeft) : null,
        'user_message_label': userMessageLabel,
      };

  Map<String, dynamic> get toMapLong => <String, dynamic>{
        'id': id,
        ...toMap,
      };

  Map<String, dynamic> get toMapShort => <String, dynamic>{
        'name': name,
        'contact': contact,
        'address': address,
        'zip_code': zipCode,
        'city': city,
        'iban': iban,
        'bic': bic,
        'bank': bank,
        'tax_nr': taxNr,
        'vat_nr': vatNr,
        'website': website,
        'full_address': fullAddress,
        'bill_prefix': billPrefix,
        'default_due_days': defaultDueDays,
        'default_tax': defaultTax,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vendor && runtimeType == other.runtimeType && id == other.id;

  @override
  String toString() => '[Vendor $id $toMap]';
}
