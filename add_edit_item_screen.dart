// lib/screens/add_edit_item_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_picker/image_picker.dart';

import '../models/item.dart';
import '../providers/item_provider.dart';
import '../services/cloudinary_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item? item;

  const AddEditItemScreen({Key? key, this.item}) : super(key: key);

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _category;
  late int _quantity;
  late String _unit;
  late String _location;
  late String _supplier;
  late String _sku;

  String _imageUrl = "";
  File? _localImageFile;

  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _name = widget.item?.name ?? '';
    _category = widget.item?.category ?? '';
    _quantity = widget.item?.quantity ?? 0;
    _unit = widget.item?.unit ?? '';
    _location = widget.item?.location ?? '';
    _supplier = widget.item?.supplier ?? '';
    _sku = widget.item?.sku ?? '';
    _imageUrl = widget.item?.imagePath ?? "";
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _localImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadToCloudinary() async {
    if (_localImageFile == null) {
      _showError("Select an image first!");
      return;
    }

    _showLoading("Uploading image...");

    try {
      final url = await _cloudinaryService.uploadImage(_localImageFile!);

      Navigator.pop(context);

      if (url != null) {
        setState(() {
          _imageUrl = url;
        });
        _showSuccess("Image uploaded successfully!");
      } else {
        _showError("Upload failed!");
      }
    } catch (e) {
      Navigator.pop(context);
      _showError("Upload failed: $e");
    }
  }

  void _showLoading(String msg) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      dismissOnTouchOutside: false,
      body: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(msg),
        ],
      ),
    ).show();
  }

  void _showSuccess(String msg) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: "Success",
      desc: msg,
    ).show();
  }

  void _showError(String msg) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: "Error",
      desc: msg,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final isEditing = widget.item != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          isEditing ? 'Edit Item' : 'Add Item',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.indigo.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Image Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _localImageFile != null
                        ? Image.file(
                      _localImageFile!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : (_imageUrl.isNotEmpty
                        ? Image.network(
                      _imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      'assets/inventory_banner.png',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )),
                  ),
                  const SizedBox(height: 12),

                  // Select/Upload buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text("Select Image"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _uploadToCloudinary,
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text("Upload"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Form fields
                  _buildTextField(
                    label: 'Item Name',
                    icon: Icons.inventory_2_rounded,
                    initialValue: _name,
                    onSaved: (val) => _name = val!,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Category',
                    icon: Icons.category_rounded,
                    initialValue: _category,
                    onSaved: (val) => _category = val!,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Quantity',
                    icon: Icons.confirmation_number_rounded,
                    initialValue: _quantity.toString(),
                    inputType: TextInputType.number,
                    validator: (val) => val == null || int.tryParse(val) == null
                        ? 'Enter valid quantity'
                        : null,
                    onSaved: (val) => _quantity = int.parse(val!),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Unit',
                    icon: Icons.straighten_rounded,
                    initialValue: _unit,
                    onSaved: (val) => _unit = val!,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Location',
                    icon: Icons.location_on_rounded,
                    initialValue: _location,
                    onSaved: (val) => _location = val!,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Supplier',
                    icon: Icons.person_rounded,
                    initialValue: _supplier,
                    onSaved: (val) => _supplier = val!,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'SKU',
                    icon: Icons.code_rounded,
                    initialValue: _sku,
                    onSaved: (val) => _sku = val!,
                  ),
                  const SizedBox(height: 30),

                  // Submit button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                    ),
                    icon: const Icon(Icons.save_rounded, color: Colors.white),
                    label: Text(
                      isEditing ? 'Update Item' : 'Add Item',
                      style: GoogleFonts.poppins(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        if (_imageUrl.isEmpty) {
                          _showError("Upload an image first!");
                          return;
                        }

                        Item resultItem = Item(
                          id: isEditing ? widget.item!.id : null,
                          name: _name,
                          category: _category,
                          quantity: _quantity,
                          unit: _unit,
                          location: _location,
                          supplier: _supplier,
                          sku: _sku,
                          imagePath: _imageUrl,
                          dateAdded: DateTime.now().toString(),
                        );

                        if (isEditing) {
                          await itemProvider.updateItem(resultItem);
                        } else {
                          await itemProvider.addItem(resultItem);
                        }

                        _showSuccess(isEditing
                            ? "Item updated successfully!"
                            : "Item added successfully!");

                        Navigator.pop(context, resultItem);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String?) onSaved,
    String? initialValue,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.indigo.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
      validator: validator ??
              (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
      onSaved: onSaved,
    );
  }
}
