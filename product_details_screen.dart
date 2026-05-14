import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import '../services/firestore_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String barcode;

  const ProductDetailsScreen({
    super.key,
    required this.barcode,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final FirestoreService _firestore = FirestoreService();
  bool _saving = false;
  bool _showSavedAnimation = false;

  Future<void> _saveToFirestore() async {
    setState(() {
      _saving = true;
    });

    final payload = {
      'barcode': widget.barcode,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await _firestore.saveScannedProduct(payload);

      setState(() {
        _saving = false;
        _showSavedAnimation = true;
      });

      await Future.delayed(const Duration(milliseconds: 1500));
      setState(() {
        _showSavedAnimation = false;
      });

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Saved',
        desc: 'Product has been saved to your inventory.',
      ).show();
    } catch (e) {
      setState(() {
        _saving = false;
      });
      _showError("Failed to save: $e");
    }
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Product Details",
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 40),
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Image.asset(
                    'assets/qr_result.png',
                    height: 150,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Scanned Barcode",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.barcode,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _saveToFirestore,
                        icon: _saving ? const SizedBox.shrink() : const Icon(Icons.save),
                        label: _saving
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text("Saving...", style: GoogleFonts.poppins()),
                          ],
                        )
                            : Text("Save to Inventory", style: GoogleFonts.poppins()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryYellow,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Close", style: GoogleFonts.poppins(color: AppTheme.textDark)),
                    ),
                  ],
                ),
              ],
            ),

            if (_showSavedAnimation)
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18),
                    ],
                  ),
                  child: Lottie.network(
                    'https://assets7.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                    repeat: false,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
