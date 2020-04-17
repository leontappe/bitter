import 'dart:convert';

import 'package:meta/meta.dart';

class Vendor {
  int id;
  String name;
  String contact;
  String address;
  String city;
  String iban;
  String bic;
  String bank;
  String taxNr;
  String vatNr;
  String website;

  String fullAddress;
  String billPrefix;

  List<int> headerImage;

  Vendor({
    this.id,
    @required this.name,
    @required this.contact,
    @required this.address,
    @required this.city,
    @required this.iban,
    @required this.bic,
    @required this.bank,
    this.taxNr,
    this.vatNr,
    this.website,
    @required this.fullAddress,
    @required this.billPrefix,
    this.headerImage,
  });

  factory Vendor.empty() => Vendor(
        name: null,
        contact: null,
        address: null,
        city: null,
        iban: null,
        bic: null,
        bank: null,
        fullAddress: null,
        billPrefix: null,
      );

  factory Vendor.fromMap(Map map) => Vendor(
        id: map['id'] as int,
        name: map['name'].toString(),
        contact: map['contact'].toString(),
        address: map['address'].toString(),
        city: map['city'].toString(),
        iban: map['iban'].toString(),
        bic: map['bic'].toString(),
        bank: map['bank'].toString(),
        taxNr: map['tax_nr'].toString(),
        vatNr: map['vat_nr'].toString(),
        website: (map['website'] != null) ? map['website'].toString() : null,
        fullAddress: map['full_address'].toString(),
        billPrefix: map['bill_prefix'].toString(),
        headerImage:
            (map['header_image'] != null) ? base64.decode(map['header_image'].toString()) : null,
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'name': name,
        'contact': contact,
        'address': address,
        'city': city,
        'iban': iban,
        'bic': bic,
        'bank': bank,
        'tax_nr': taxNr,
        'vat_nr': vatNr,
        'website': website,
        'full_address': fullAddress,
        'bill_prefix': billPrefix,
        'header_image': (headerImage != null) ? base64.encode(headerImage) : null,
      };

  Map<String, dynamic> get toMapLong => <String, dynamic>{
        'id': id,
        ...toMap,
      };

  @override
  String toString() => '[Vendor $id $toMap]';
}
