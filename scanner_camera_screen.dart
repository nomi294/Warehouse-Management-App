import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'product_details_screen.dart';
import '../theme/app_theme.dart';

class ScannerCameraScreen extends StatefulWidget {
  const ScannerCameraScreen({super.key});

  @override
  State<ScannerCameraScreen> createState() => _ScannerCameraScreenState();
}

class _ScannerCameraScreenState extends State<ScannerCameraScreen> {
  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;
    _isScanned = true;

    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) {
      Navigator.pop(context);
      return;
    }

    // Navigate to ProductDetailsScreen with the barcode only
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          barcode: barcode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text("Scan Product Barcode"),
        backgroundColor: Colors.black87,
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),

          // Overlay for scanning
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryYellow,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
