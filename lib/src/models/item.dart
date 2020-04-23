import 'package:meta/meta.dart';

class Item {
  int id;
  String uid;

  int vendor;
  int itemId;

  String title;
  int price;
  int tax;
  int quantity;
  String description;

  Item({
    this.uid,
    this.id,
    this.vendor,
    this.itemId,
    @required this.title,
    @required this.price,
    @required this.tax,
    this.quantity = 1,
    this.description,
  });

  factory Item.empty() => Item(title: null, price: null, tax: null);

  factory Item.fromDbMap(Map map) => Item(
        id: map['id'] as int,
        vendor: map['vendor'] as int,
        itemId: map['item_id'] as int,
        title: map['title'].toString(),
        price: map['price'] as int,
        tax: map['tax'] as int,
        quantity: map['quantity'] as int,
        description: map['description'].toString(),
      );

  factory Item.fromMap(Map map) => Item(
        title: map['title'] as String,
        price: map['price'] as int,
        tax: map['tax'] as int,
        quantity: map['quantity'] as int,
        description: map['description'] as String,
      );

  @override
  int get hashCode => uid.hashCode;

  int get sum => price * quantity;

  Map<String, dynamic> get toMap => <String, dynamic>{
        'item_id': itemId,
        'title': title,
        'description': description,
        'price': price,
        'tax': tax,
        'quantity': quantity,
        'vendor': vendor,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          ((uid != null) ? uid == other.uid : id == other.id);

  @override
  String toString() => '[Item $id $uid $toMap]';
}
