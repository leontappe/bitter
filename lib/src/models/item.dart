import 'package:meta/meta.dart';

class Item {
  int id;

  String title;
  int price;
  int tax;
  int quantity;
  String description;

  int get sum => price * quantity;

  Item({
    this.id,
    @required this.title,
    @required this.price,
    this.tax = 0,
    this.quantity = 1,
    this.description,
  });

  factory Item.empty() => Item(title: null, price: null);

  factory Item.fromMap(Map map) => Item(
        title: map['title'],
        price: map['price'],
        tax: map['tax'],
        quantity: map['quantity'],
        description: map['description'],
      );

  Map<String, dynamic> get toMap => <String, dynamic>{
        'title': title,
        'price': price,
        'tax': tax,
        'quantity': quantity,
        'description': description,
      };

  @override
  String toString() => '[Item $toMap]';
}
