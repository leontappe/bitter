import 'dart:convert';

import 'package:meta/meta.dart';

import 'reminder.dart';

enum HeaderImage {
  right,
  center,
  left,
}

class Vendor {
  static final shortKeys = <String>[
    'id',
    'name',
    'manager',
    'contact',
    'address',
    'zip_code',
    'city',
    'iban',
    'bic',
    'bank',
    'tax_nr',
    'vat_nr',
    'email',
    'website',
    'full_address',
    'bill_prefix',
  ];

  int id;
  String name;
  String manager;
  String contact;
  String address;
  int zipCode;
  String city;
  String iban;
  String bic;
  String bank;
  String taxNr;
  String vatNr;
  String email;

  String website;
  String fullAddress;

  String billPrefix;
  int defaultDueDays;
  int defaultTax;

  String defaultComment;

  int reminderDeadline;
  Map<ReminderIteration, int> reminderFees;
  Map<ReminderIteration, String> reminderTexts;
  Map<ReminderIteration, String> reminderTitles;

  List<int> headerImageRight;
  List<int> headerImageCenter;
  List<int> headerImageLeft;

  String userMessageLabel;

  Vendor({
    this.id,
    @required this.name,
    this.manager,
    this.contact,
    @required this.address,
    @required this.zipCode,
    @required this.city,
    @required this.iban,
    @required this.bic,
    @required this.bank,
    this.taxNr,
    this.vatNr,
    @required this.email,
    this.website,
    @required this.fullAddress,
    @required this.billPrefix,
    this.defaultDueDays,
    this.defaultTax,
    this.defaultComment,
    this.reminderDeadline,
    this.reminderFees = const <ReminderIteration, int>{
      ReminderIteration.first: 0,
      ReminderIteration.second: 500,
      ReminderIteration.third: 500,
    },
    this.reminderTexts = const <ReminderIteration, String>{},
    this.reminderTitles = const <ReminderIteration, String>{},
    this.headerImageRight,
    this.headerImageCenter,
    this.headerImageLeft,
    this.userMessageLabel,
  });

  factory Vendor.empty() => Vendor(
        name: null,
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
        reminderDeadline: 14,
        email: null,
      );

  factory Vendor.fromMap(Map map) => Vendor(
        id: map['id'] as int,
        name: map['name'].toString(),
        manager: map['manager']?.toString(),
        contact: map['contact']?.toString(),
        address: map['address'].toString(),
        zipCode: int.parse(map['zip_code'].toString()),
        city: map['city'].toString(),
        iban: map['iban'].toString(),
        bic: map['bic'].toString(),
        bank: map['bank'].toString(),
        taxNr: map['tax_nr'].toString(),
        vatNr: map['vat_nr'].toString(),
        email: map['email'].toString(),
        website: (map['website'] != null) ? map['website'].toString() : null,
        fullAddress: map['full_address'].toString(),
        billPrefix: map['bill_prefix'].toString(),
        defaultDueDays: map['default_due_days'] as int,
        defaultTax: map['default_tax'] as int,
        defaultComment: map['default_comment']?.toString(),
        reminderDeadline: (map['reminder_deadline'] != null) ? map['reminder_deadline'] as int : 14,
        reminderFees: (map['reminder_fees'] != null)
            ? ((json.decode(map['reminder_fees'].toString()) as Map) ?? <dynamic, dynamic>{})
                .map<ReminderIteration, int>((dynamic key, dynamic value) {
                final iter = parseIteration(int.parse(key as String));
                if (iter == null) return null;
                return MapEntry(iter, value as int);
              })
            : <ReminderIteration, int>{},
        reminderTexts: (map['reminder_texts'] != null)
            ? ((json.decode(map['reminder_texts'].toString()) as Map) ?? <dynamic, dynamic>{})
                .map<ReminderIteration, String>((dynamic key, dynamic value) {
                final iter = parseIteration(int.parse(key as String));
                if (iter == null) return null;
                return MapEntry(iter, value as String);
              })
            : <ReminderIteration, String>{},
        reminderTitles: (map['reminder_titles'] != null)
            ? ((json.decode(map['reminder_titles'].toString()) as Map) ?? <dynamic, dynamic>{})
                .map<ReminderIteration, String>((dynamic key, dynamic value) {
                final iter = parseIteration(int.parse(key as String));
                if (iter == null) return null;
                return MapEntry(iter, value as String);
              })
            : <ReminderIteration, String>{},
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
  int get hashCode => id.hashCode;

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
        'manager': manager,
        'contact': contact,
        'address': address,
        'zip_code': zipCode,
        'city': city,
        'iban': iban,
        'bic': bic,
        'bank': bank,
        'tax_nr': taxNr,
        'vat_nr': vatNr,
        'email': email,
        'website': website,
        'full_address': fullAddress,
        'bill_prefix': billPrefix,
        'default_due_days': defaultDueDays,
        'default_tax': defaultTax,
        'default_comment': defaultComment,
        'reminder_deadline': reminderDeadline,
        'reminder_fees': json.encode(reminderFees.map<String, int>(
            (ReminderIteration key, int value) => MapEntry(key.index.toString(), value))),
        'reminder_texts': json.encode(reminderTexts.map<String, String>(
            (ReminderIteration key, String value) => MapEntry(key.index.toString(), value))),
        'reminder_titles': json.encode(reminderTitles.map<String, String>(
            (ReminderIteration key, String value) => MapEntry(key.index.toString(), value))),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vendor && runtimeType == other.runtimeType && id == other.id;

  @override
  String toString() => '[Vendor $id $toMapShort]';
}
