import 'dart:convert';
import 'package:http/http.dart' as http;

/// Modèle Produit (id + nom)
class Product {
  final int id;
  final String name;
  Product(this.id, this.name);
}

/// Service qui charge les produits favoris pour un acteur donné via une API.
class FavoriteProductService {
  static const _baseUrl = 'http://localhost:3001';
  /// Récupère la liste des Product (id + name) depuis l'API
  static Future<List<Product>> fetchFavorites(int actorId) async {
    final url = Uri.parse('$_baseUrl/favorite-products?actor_id=$actorId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['favorites'];

      return data.map((row) {
        return Product(
          row['product_id'] as int,
          row['product']['name'] as String,
        );
      }).toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }
}