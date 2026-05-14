import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/firebase_employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final FirebaseEmployeeService _service = FirebaseEmployeeService();

  List<Employee> _employees = [];
  List<Employee> get employees => _employees;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  EmployeeProvider() {
    _loadEmployees();
  }

  void _loadEmployees() {
    _service.getEmployeesStream().listen((data) {
      _employees = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addEmployee(Employee emp) async {
    await _service.addEmployee(emp);
  }

  Future<void> updateEmployee(Employee emp) async {
    await _service.updateEmployee(emp);
  }

  Future<void> deleteEmployee(String id) async {
    await _service.deleteEmployee(id);
  }

  List<Employee> searchEmployees(String query) {
    query = query.toLowerCase();
    return _employees.where((emp) =>
    emp.name.toLowerCase().contains(query) ||
        emp.role.toLowerCase().contains(query)).toList();
  }
}
