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
        company: map['company'] as String,
        organizationUnit: map['organization_unit'] as String,
        name: map['name'] as String,
        surname: map['surname'] as String,
        gender: (map['gender'] == 0)
            ? Gender.male
            : (map['gender'] == 1) ? Gender.diverse : Gender.diverse,
        address: map['address'] as String,
        zipCode: map['zip_code'] as int,
        city: map['city'] as String,
        country: map['country'] as String,
        telephone: map['telephone'] as String,
        fax: map['fax'] as String,
        mobile: map['mobile'] as String,
        email: map['email'] as String,
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

  @override
  String toString() => '[Customer $id $toMap]';
}

enum Gender {
  male,
  female,
  diverse,
}
