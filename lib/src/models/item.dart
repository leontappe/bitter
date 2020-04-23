import 'package:meta/meta.dart';

class Item {
  String id;

  String title;
  int price;
  int tax;
  int quantity;
  String description;

  Item({
    this.id,
    @required this.title,
    @required this.price,
    @required this.tax,
    this.quantity = 1,
    this.description,
  });

  factory Item.empty() => Item(title: null, price: null, tax: null);

  factory Item.fromMap(Map map) => Item(
        title: map['title'] as String,
        price: map['price'] as int,
        tax: map['tax'] as int,
        quantity: map['quantity'] as int,
        description: map['description'] as String,
      );

  @override
  int get hashCode => id.hashCode;

  int get sum => price * quantity;

  Map<String, dynamic> get toMap => <String, dynamic>{
        'title': title,
        'price': price,
        'tax': tax,
        'quantity': quantity,
        'description': description,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  String toString() => '[Item $id $toMap]';
}
