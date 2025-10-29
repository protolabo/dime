import 'dart:convert';
import 'package:http/http.dart' as http;
class OffProduct {
  final String barcode;
  final String? name;
  final String? brand;
  final String? description;
  final String? imageUrl;
  final String? quantity;

  OffProduct({
    required this.barcode,
    this.name,
    this.brand,
    this.description,
    this.imageUrl,
    this.quantity,
  });

  factory OffProduct.fromJson(String barcode, Map<String, dynamic> json) {
    final name = (json['product_name'] as String?)?.trim();
    final generic = (json['generic_name'] as String?)?.trim();
    final categories = (json['categories'] as String?)?.trim();
    return OffProduct(
      barcode: barcode,
      name: name?.isNotEmpty == true ? name : (generic?.isNotEmpty == true ? generic : null),
      brand: (json['brands'] as String?)?.trim(),
      description: generic?.isNotEmpty == true ? generic : categories,
      imageUrl: (json['image_url'] as String?)?.trim(),
      quantity: (json['quantity'] as String?)?.trim(),
    );
  }
}

class OpenFoodFactsService {
  static Future<OffProduct?> fetchProduct(String barcode) async {
    if (barcode.isEmpty) return null;
    final uri = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
    final resp = await http.get(uri, headers: {'Accept': 'application/json'});
    // print('OFF response status: ${resp.statusCode}');
    // print('OFF response body: ${resp.body}');
    if (resp.statusCode != 200) return null;

    final map = jsonDecode(resp.body) as Map<String, dynamic>;
    final status = map['status'] as int?; // 1 = trouvé 0 = introuvable
    if (status != 1) return null;

    final product = map['product'] as Map<String, dynamic>?;
    if (product == null) return null;

    return OffProduct.fromJson(barcode, product);
  }
}
