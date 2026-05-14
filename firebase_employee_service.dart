import '../models/employee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class FirebaseEmployeeService {
  final CollectionReference employeesRef =
  FirebaseFirestore.instance.collection('employees');

  /// Add employee
  Future<void> addEmployee(Employee employee) async {
    final doc = employeesRef.doc(); // auto ID
    await doc.set({
      'id': doc.id,
      'name': employee.name,
      'role': employee.role,
      'contact': employee.contact,
      'assignedSection': employee.assignedSection,
    });
  }

  /// Update employee
  Future<void> updateEmployee(Employee employee) async {
    await employeesRef.doc(employee.id.toString()).update({
      'name': employee.name,
      'role': employee.role,
      'contact': employee.contact,
      'assignedSection': employee.assignedSection,
    });
  }

  /// Delete employee
  Future<void> deleteEmployee(String id) async {
    await employeesRef.doc(id).delete();
  }

  /// Stream employees LIVE
  Stream<List<Employee>> getEmployeesStream() {
    return employeesRef.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Employee.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Load once
  Future<List<Employee>> getEmployeesOnce() async {
    final snapshot = await employeesRef.orderBy('name').get();
    return snapshot.docs
        .map((doc) => Employee.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
