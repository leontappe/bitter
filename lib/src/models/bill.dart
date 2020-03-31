import 'dart:convert';

import 'package:meta/meta.dart';

class Bill {
  int id;

  String billNr;
  List<int> file;
  final DateTime created;

  Bill({this.id, @required this.billNr, @required this.file, @required this.created});

  factory Bill.empty() => Bill(billNr: null, created: null, file: null);

  factory Bill.fromMap(Map map) => Bill(
        id: map['id'] as int,
        billNr: map['bill_nr'].toString(),
        file: base64.decode(map['file'].toString()),
        created: DateTime.parse(map['created'].toString()),
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'bill_nr': billNr,
        'file': base64.encode(file),
        'created': created,
      };

  @override
  String toString() => '[Bill $id $toMap]';
}
