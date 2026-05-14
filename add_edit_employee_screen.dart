// lib/screens/add_edit_employee_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../models/employee.dart';
import '../providers/employee_provider.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  final Employee? employee;
  const AddEditEmployeeScreen({Key? key, this.employee}) : super(key: key);

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _role;
  late String _contact;
  late String _assignedSection;

  @override
  void initState() {
    super.initState();
    _name = widget.employee?.name ?? '';
    _role = widget.employee?.role ?? '';
    _contact = widget.employee?.contact ?? '';
    _assignedSection = widget.employee?.assignedSection ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.read<EmployeeProvider>();
    final isEditing = widget.employee != null;

    final primaryColor = Colors.indigo.shade600;
    final bgColor = Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 6,
        centerTitle: true,
        title: Text(
          isEditing ? "Edit Employee" : "Add Employee",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade500, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 700),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.indigo.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.indigo.shade100, blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/employee_banner.png',
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(label: "Name", initialValue: _name, icon: Icons.person_outline, onSaved: (val) => _name = val!),
                      const SizedBox(height: 16),
                      _buildTextField(label: "Role", initialValue: _role, icon: Icons.work_outline, onSaved: (val) => _role = val!),
                      const SizedBox(height: 16),
                      _buildTextField(label: "Contact", initialValue: _contact, icon: Icons.phone, keyboardType: TextInputType.phone, onSaved: (val) => _contact = val!),
                      const SizedBox(height: 16),
                      _buildTextField(label: "Assigned Section", initialValue: _assignedSection, icon: Icons.warehouse_outlined, onSaved: (val) => _assignedSection = val!),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 5),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();


                                if (isEditing) {
                                  final updatedEmployee = Employee(
                                    id: widget.employee!.id,
                                    name: _name,
                                    role: _role,
                                    contact: _contact,
                                    assignedSection: _assignedSection,
                                  );
                                  await employeeProvider.updateEmployee(updatedEmployee);
                                } else {
                                  final newEmployee = Employee(
                                    name: _name,
                                    role: _role,
                                    contact: _contact,
                                    assignedSection: _assignedSection,
                                  );
                                  await employeeProvider.addEmployee(newEmployee);
                                }

                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.scale,
                                title: "Success!",
                                desc: isEditing
                                    ? "Employee details have been successfully updated."
                                    : "New employee added successfully!",
                                btnOkColor: Colors.indigo,
                                btnOkText: "Done",
                                btnOkOnPress: () => Navigator.pop(context),
                                dismissOnTouchOutside: false,
                              ).show();
                            }
                          },
                          child: Text(
                            isEditing ? "Update Employee" : "Add Employee",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String initialValue, required IconData icon, TextInputType? keyboardType, required Function(String?) onSaved}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.indigo),
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.indigo.shade600, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.indigo.shade100, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.indigo, width: 2)),
      ),
      keyboardType: keyboardType,
      validator: (val) => val == null || val.isEmpty ? "Please enter $label" : null,
      onSaved: onSaved,
    );
  }
}
