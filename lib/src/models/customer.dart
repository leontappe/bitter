import 'package:meta/meta.dart';

class Customer {
  int id;

  String company;
  String organizationUnit;
  String name;
  String surname;
  Gender gender;
  String address;
  int zipCode;
  String city;
  String country;
  String telephone;
  String fax;
  String mobile;
  String email;

  String get fullName => '$name $surname';
  String get fullCompany => (company != null)
      ? '$company${(organizationUnit != null && organizationUnit.isNotEmpty) ? ' ' + organizationUnit : ''} - $name $surname'
      : null;

  Customer({
    this.id,
    this.company,
    this.organizationUnit,
    @required this.name,
    @required this.surname,
    @required this.gender,
    @required this.address,
    @required this.zipCode,
    @required this.city,
    this.country,
    this.telephone,
    this.fax,
    this.mobile,
    @required this.email,
  });

  factory Customer.empty() => Customer(
        name: null,
        surname: null,
        gender: null,
        address: null,
        zipCode: null,
        city: null,
        email: null,
      );

  factory Customer.fromMap(Map map) => Customer(
        id: map['id'] as int,
        company: (map['company'] != null) ? map['company'].toString() : null,
        organizationUnit:
            (map['organization_unit'] != null) ? map['organization_unit'].toString() : null,
        name: map['name'].toString(),
        surname: map['surname'].toString(),
        gender: (map['gender'] == 0)
            ? Gender.male
            : (map['gender'] == 1) ? Gender.diverse : Gender.diverse,
        address: map['address'].toString(),
        zipCode: map['zip_code'] as int,
        city: map['city'].toString(),
        country: (map['country'] != null) ? map['country'].toString() : null,
        telephone: (map['telephone'] != null) ? map['telephone'].toString() : null,
        fax: (map['fax'] != null) ? map['fax'].toString() : null,
        mobile: (map['mobile'] != null) ? map['mobile'].toString() : null,
        email: map['email'].toString(),
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'company': company,
        'organization_unit': organizationUnit,
        'name': name,
        'surname': surname,
        'gender': gender.index,
        'address': address,
        'zip_code': zipCode,
        'city': city,
        'country': country,
        'telephone': telephone,
        'fax': fax,
        'mobile': mobile,
        'email': email,
      };

  Map<String, dynamic> get toMapLong => <String, dynamic>{
        'id': id,
        ...toMap,
      };

  Map<String, dynamic> get toShortMap => <String, dynamic>{
        if (company != null) 'company': company,
        if (organizationUnit != null) 'organization_unit': organizationUnit,
        'name': name,
        'surname': surname,
        'gender': gender.index,
        'address': address,
        'zip_code': zipCode,
        'city': city,
        if (country != null) 'country': country,
        if (telephone != null) 'telephone': telephone,
        if (fax != null) 'fax': fax,
        if (mobile != null) 'mobile': mobile,
        'email': email,
      };

  @override
  String toString() => '[Customer $id $toMap]';
}

enum Gender {
  male,
  female,
  diverse,
}
