import 'dart:convert';

class Crate {
  String? name;
  String uid;
  int size;
  int level;
  int? itemId;
  Crate? subcrate;

  Crate(
    this.uid, {
    this.name,
    this.size = 0,
    this.level = 0,
    this.itemId,
    this.subcrate,
  }) {
    //assert(itemId != null && subcrate == null || itemId == null && subcrate != null);
  }

  factory Crate.fromMap(Map<String, dynamic> map) => Crate(
        map['uid'] as String,
        name: map['name'] as String,
        size: map['size'] as int,
        level: (map['level'] as int) ?? 0,
        itemId: map['item_id'] as int,
        subcrate: map['subcrate'] != null
            ? Crate.fromMap(
                json.decode(map['subcrate'] as String) as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'uid': uid,
        'name': name,
        'size': size,
        'level': level,
        'item_id': itemId,
        'subcrate': subcrate?.toMap,
      };

  @override
  String toString() => 'Crate [$toMap]';
}
