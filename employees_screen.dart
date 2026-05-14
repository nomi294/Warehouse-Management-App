import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../models/employee.dart';
import '../providers/employee_provider.dart';
import 'add_edit_employee_screen.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final displayedEmployees = _searchQuery.isEmpty
        ? employeeProvider.employees
        : employeeProvider.searchEmployees(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text('Employees', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _EmployeeSearchDelegate(employeeProvider.employees),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: displayedEmployees.isEmpty
            ? Center(
          child: Text('No employees found.', style: GoogleFonts.poppins(fontSize: 16)),
        )
            : ListView.builder(
          itemCount: displayedEmployees.length,
          itemBuilder: (context, index) {
            final emp = displayedEmployees[index];
            return FadeInUp(
              duration: Duration(milliseconds: 300 + index * 100),
              child: _EmployeeCard(emp),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Employee?>(
            context,
            MaterialPageRoute(builder: (_) => const AddEditEmployeeScreen()),
          );

          // If new employee is returned, add it directly to provider
          if (result != null) {
            await employeeProvider.addEmployee(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Reusable Employee Card
class _EmployeeCard extends StatelessWidget {
  final Employee emp;

  const _EmployeeCard(this.emp, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(emp.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Role: ${emp.role}\nContact: ${emp.contact}\nSection: ${emp.assignedSection}',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final updatedEmployee = await Navigator.push<Employee?>(
                  context,
                  MaterialPageRoute(builder: (_) => AddEditEmployeeScreen(employee: emp)),
                );

                if (updatedEmployee != null) {
                  await employeeProvider.updateEmployee(updatedEmployee);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Delete Employee', style: GoogleFonts.poppins()),
                    content: Text('Are you sure you want to delete ${emp.name}?', style: GoogleFonts.poppins()),
                    actions: [
                      TextButton(
                        child: Text('Cancel', style: GoogleFonts.poppins()),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: Text('Delete', style: GoogleFonts.poppins()),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await employeeProvider.deleteEmployee(emp.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Search Delegate for Employee
class _EmployeeSearchDelegate extends SearchDelegate {
  final List<Employee> employees;

  _EmployeeSearchDelegate(this.employees);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
  ];

  @override
  Widget? buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) =>
      _buildResultsList(employees.where((e) => e.name.toLowerCase().contains(query.toLowerCase()) || e.role.toLowerCase().contains(query.toLowerCase())).toList());

  @override
  Widget buildSuggestions(BuildContext context) =>
      _buildResultsList(employees.where((e) => e.name.toLowerCase().contains(query.toLowerCase()) || e.role.toLowerCase().contains(query.toLowerCase())).toList());

  Widget _buildResultsList(List<Employee> list) {
    if (list.isEmpty) {
      return Center(child: Text('No employees found.', style: GoogleFonts.poppins(fontSize: 16)));
    }
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => FadeInUp(
        duration: Duration(milliseconds: 200 + index * 100),
        child: _EmployeeCard(list[index]),
      ),
    );
  }
}
