import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final ImageProvider? profileImage; // <-- Now accepts NetworkImage or AssetImage

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    // Here, save updated data locally or to Firestore if needed
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
              color: AppTheme.textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
                _isEditing ? Icons.check : Icons.edit,
                color: AppTheme.primaryYellow
            ),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: widget.profileImage,
                child: widget.profileImage == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 800),
              child: Column(
                children: [
                  _buildTextField("Full Name", _nameController, false),
                  const SizedBox(height: 16),
                  _buildTextField("Email", _emailController, false,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField("Phone", _phoneController, false,
                      keyboardType: TextInputType.phone),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      readOnly: !_isEditing,
      keyboardType: keyboardType,
      obscureText: isPassword,
      style: GoogleFonts.poppins(color: AppTheme.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: isPassword ? const Icon(Icons.lock_outline) : null,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.primaryYellow, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
