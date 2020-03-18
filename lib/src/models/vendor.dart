import 'package:meta/meta.dart';

class Vendor {
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
        name: map['name'] as String,
        address: map['address'] as String,
        city: map['city'] as String,
        iban: map['iban'] as String,
        bic: map['bic'] as String,
        bank: map['bank'] as String,
        taxNr: map['tax_nr'] as String,
        vatNr: map['vat_nr'] as String,
        website: map['website'] as String,
        fullAdress: map['full_address'] as String,
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
  String toString() => '[Vendor $toMap]';
}
