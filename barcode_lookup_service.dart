import 'dart:convert';
import 'package:http/http.dart' as http;

class BarcodeProduct {
  final String? barcode;
  final String? title;
  final String? brand;
  final String? origin;
  final String? manufacturer;
  final String? ingredients;
  final List<String>? images;

  BarcodeProduct({
    this.barcode,
    this.title,
    this.brand,
    this.origin,
    this.manufacturer,
    this.ingredients,
    this.images,
  });

  factory BarcodeProduct.fromJson(Map<String, dynamic> json) {
    final product = json['product'] ?? json;
    return BarcodeProduct(
      barcode: product['barcode']?.toString(),
      title: product['title'] ?? product['product_name'],
      brand: product['brand'] ?? product['brands'],
      origin: product['origin'] ?? product['countries'],
      manufacturer: product['manufacturer'],
      ingredients: product['ingredients'] ?? product['ingredients_text'],
      images: (product['images'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

class BarcodeLookupService {
  // Replace with your BarcodeLookup API key
  final String apiKey;

  BarcodeLookupService({required this.apiKey});

  /// Fetch product info for [barcode]
  Future<BarcodeProduct?> fetchProduct(String barcode) async {
    try {
      final url =
      Uri.parse('https://api.barcodelookup.com/v3/products?barcode=$barcode&key=$apiKey');

      final resp = await http.get(url).timeout(const Duration(seconds: 12));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        // BarcodeLookup returns "products": [ { product... } ] or "product"
        Map<String, dynamic>? productJson;
        if (data['products'] != null && data['products'] is List && data['products'].isNotEmpty) {
          productJson = {'product': data['products'][0]};
        } else if (data['product'] != null) {
          productJson = {'product': data['product']};
        } else {
          productJson = data;
        }
        return BarcodeProduct.fromJson(productJson!);
      } else {
        // non-200
        // optional: parse error message
        return null;
      }
    } catch (e) {
      // network/parse error
      return null;
    }
  }
}
