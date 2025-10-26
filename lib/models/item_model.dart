class Item {
  final int? id;
  final String name;
  final int quantity;
  final double price;
  final String? imagePath;

  Item({this.id, this.imagePath, required this.name, required this.quantity, required this.price});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imagePath': imagePath,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      imagePath: map['imagePath'],
    );
  }
}
