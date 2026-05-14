class Item {
  String? id; // Firestore document ID
  String name;
  String category;
  int quantity;
  String unit;
  String location;
  String supplier;
  String dateAdded;
  String? sku;
  String? imagePath;

  Item({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.location,
    required this.supplier,
    required this.dateAdded,
    this.sku,
    this.imagePath,
  });

  /// 🔥 Safe image getter (always return a valid image)
  String getImage() {
    if (imagePath == null || imagePath!.isEmpty) {
      return 'assets/images/default_item.png';
    }
    return imagePath!;
  }

  /// Convert Item → Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'location': location,
      'supplier': supplier,
      'dateAdded': dateAdded,
      'sku': sku,
      'imagePath': imagePath,
    };
  }

  /// Convert Firestore → Item
  factory Item.fromMap(String id, Map<String, dynamic> map) {
    return Item(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? '',
      location: map['location'] ?? '',
      supplier: map['supplier'] ?? '',
      dateAdded: map['dateAdded'] ?? '',
      sku: map['sku'],
      imagePath: map['imagePath'],
    );
  }
}
