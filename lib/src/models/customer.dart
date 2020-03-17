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
        id: map['id'],
        company: map['company'],
        organizationUnit: map['organization_unit'],
        name: map['name'],
        surname: map['surname'],
        gender: (map['gender'] == 0)
            ? Gender.male
            : (map['gender'] == 1) ? Gender.diverse : Gender.diverse,
        address: map['address'],
        zipCode: map['zip_code'],
        city: map['city'],
        country: map['country'],
        telephone: map['telephone'],
        fax: map['fax'],
        mobile: map['mobile'],
        email: map['email'],
      );

  Map<String, dynamic> get toMap => {
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
