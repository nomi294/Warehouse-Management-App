class Employee {
  String? id;
  String name;
  String role;
  String contact;
  String assignedSection;

  Employee({
    this.id,
    required this.name,
    required this.role,
    required this.contact,
    required this.assignedSection,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'contact': contact,
      'assignedSection': assignedSection,
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      contact: map['contact'],
      assignedSection: map['assignedSection'],
    );
  }
}
