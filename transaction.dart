class WarehouseTransaction {
  String? id;
  String itemName;
  int quantity;
  String type; // in / out
  String date;

  WarehouseTransaction({
    this.id,
    required this.itemName,
    required this.quantity,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'type': type,
      'date': date,
    };
  }

  factory WarehouseTransaction.fromMap(String id, Map<String, dynamic> map) {
    return WarehouseTransaction(
      id: id,
      itemName: map['itemName'],
      quantity: map['quantity'],
      type: map['type'],
      date: map['date'],
    );
  }
}
