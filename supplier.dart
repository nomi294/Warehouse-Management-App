class Supplier {
  String? id;
  String name;
  String company;
  String contact;
  String email;
  String address;

  Supplier({
    this.id,
    required this.name,
    required this.company,
    required this.contact,
    required this.email,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company': company,
      'contact': contact,
      'email': email,
      'address': address,
    };
  }

  factory Supplier.fromMap(String id, Map<String, dynamic> map) {
    return Supplier(
      id: id,
      name: map['name'],
      company: map['company'],
      contact: map['contact'],
      email: map['email'],
      address: map['address'],
    );
  }
}
