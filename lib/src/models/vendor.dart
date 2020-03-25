import 'package:meta/meta.dart';

class Vendor {
  int id;
  String name;
  String address;
  String city;
  String iban;
  String bic;
  String bank;
  String taxNr;
  String vatNr;
  String website;

  String fullAdress;

  Vendor({
    this.id,
    @required this.name,
    @required this.address,
    @required this.city,
    @required this.iban,
    @required this.bic,
    @required this.bank,
    this.taxNr,
    this.vatNr,
    this.website,
    @required this.fullAdress,
  });

  factory Vendor.empty() => Vendor(
      name: null, address: null, city: null, iban: null, bic: null, bank: null, fullAdress: null);

  factory Vendor.fromMap(Map map) => Vendor(
        id: map['id'] as int,
        name: map['name'].toString(),
        address: map['address'].toString(),
        city: map['city'].toString(),
        iban: map['iban'].toString(),
        bic: map['bic'].toString(),
        bank: map['bank'].toString(),
        taxNr: map['tax_nr'].toString(),
        vatNr: map['vat_nr'].toString(),
        website: (map['website'] != null) ? map['website'].toString() : null,
        fullAdress: map['full_address'].toString(),
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'name': name,
        'address': address,
        'city': city,
        'iban': iban,
        'bic': bic,
        'bank': bank,
        'tax_nr': taxNr,
        'vat_nr': vatNr,
        'website': website,
        'full_address': fullAdress,
      };

  @override
  String toString() => '[Vendor $id $toMap]';
}
