import 'dart:convert';
import 'package:http/http.dart' as http;

/// Représente un commerce (id + nom)
class Store {
  final int id;
  final String name;
  Store(this.id, this.name);
}

/// Service pour charger les commerces favoris d'un acteur client
class FavoriteStoreService {
  static const _baseUrl = 'http://localhost:3001';
  /// Récupère la liste des Store (id + name) depuis l'API
  static Future<List<Store>> fetchFavorites(int actorId) async {
    final url = Uri.parse('$_baseUrl/favorite-stores?actor_id=$actorId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['favoriteStores'];

      return data.map((row) {
        return Store(
          row['store_id'] as int,
          row['store']['name'] as String,
        );
      }).toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }
}
