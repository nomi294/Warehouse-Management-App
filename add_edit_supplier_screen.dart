// lib/screens/add_edit_supplier_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../models/supplier.dart';
import '../providers/supplier_provider.dart';

class AddEditSupplierScreen extends StatefulWidget {
  final Supplier? supplier;

  const AddEditSupplierScreen({Key? key, this.supplier}) : super(key: key);

  @override
  State<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends State<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _company;
  late String _contact;
  late String _email;
  late String _address;

  @override
  void initState() {
    super.initState();
    _name = widget.supplier?.name ?? '';
    _company = widget.supplier?.company ?? '';
    _contact = widget.supplier?.contact ?? '';
    _email = widget.supplier?.email ?? '';
    _address = widget.supplier?.address ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final supplierProvider = Provider.of<SupplierProvider>(context, listen: false);
    final isEditing = widget.supplier != null;

    final primaryColor = Colors.indigo.shade600;
    final bgColor = Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 6,
        centerTitle: true,
        title: Text(
          isEditing ? "Edit Supplier" : "Add Supplier",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
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
                    BoxShadow(
                      color: Colors.indigo.shade100,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/supplier_banner.png',
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Animated text fields
                      FadeInLeft(
                        duration: const Duration(milliseconds: 600),
                        child: _buildTextField(
                          label: "Name",
                          initialValue: _name,
                          icon: Icons.person_outline,
                          onSaved: (val) => _name = val!,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 700),
                        child: _buildTextField(
                          label: "Company",
                          initialValue: _company,
                          icon: Icons.business_outlined,
                          onSaved: (val) => _company = val!,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 800),
                        child: _buildTextField(
                          label: "Contact",
                          initialValue: _contact,
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          onSaved: (val) => _contact = val!,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 900),
                        child: _buildTextField(
                          label: "Email",
                          initialValue: _email,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (val) => _email = val!,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 1000),
                        child: _buildTextField(
                          label: "Address",
                          initialValue: _address,
                          icon: Icons.location_on_outlined,
                          onSaved: (val) => _address = val!,
                        ),
                      ),
                      const SizedBox(height: 30),

                      FadeInUp(
                        duration: const Duration(milliseconds: 700),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                if (isEditing) {
                                  final updatedSupplier = Supplier(
                                    id: widget.supplier!.id, // SQLite ID
                                    name: _name,
                                    company: _company,
                                    contact: _contact,
                                    email: _email,
                                    address: _address,
                                  );
                                  await supplierProvider.updateSupplier(updatedSupplier);
                                } else {
                                  final newSupplier = Supplier(
                                    id: null, // SQLite auto-increment
                                    name: _name,
                                    company: _company,
                                    contact: _contact,
                                    email: _email,
                                    address: _address,
                                  );
                                  await supplierProvider.addSupplier(newSupplier);
                                }

                                _showSuccessDialog(context, isEditing);
                              }
                            },
                            child: Text(
                              isEditing ? "Update Supplier" : "Add Supplier",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
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

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required IconData icon,
    TextInputType? keyboardType,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.indigo),
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.indigo.shade600,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.indigo.shade100, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: (val) => val == null || val.isEmpty ? "Please enter $label" : null,
      onSaved: onSaved,
    );
  }

  void _showSuccessDialog(BuildContext context, bool isEditing) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: "Success!",
      desc: isEditing
          ? "Supplier details have been successfully updated."
          : "New supplier added successfully!",
      btnOkColor: Colors.indigo,
      btnOkText: "Done",
      btnOkOnPress: () {
        Navigator.pop(context);
      },
      dismissOnTouchOutside: false,
    ).show();
  }
}
