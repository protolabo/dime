import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CurrentStoreService {
  /* ───────────── constantes ───────────── */
  static const _prefsKey = 'current_store_id';
  static const _baseUrl = 'http://localhost:3001';

  /* ─────────── getters / setters ─────────── */

  /// ID du magasin actuellement sélectionné – peut être `null`
  static Future<int?> getCurrentStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefsKey);
  }

  /// Nom du magasin sélectionné – peut être `null`
  static Future<String?> getCurrentStoreName() async {
    final id = await getCurrentStoreId();
    if (id == null) return null;

    final url = Uri.parse('$_baseUrl/stores/?store_id=$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> favorites = data['favorites'];

      if (favorites.isNotEmpty) {
        return favorites.first['name'] as String?;
      } else {
        return null;
      }
    } else {
      throw Exception('Failed to fetch store name');
    }
  }

  /// Change le magasin courant et le persiste dans SharedPreferences
  static Future<void> setCurrentStore(int storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, storeId);
    debugPrint('🏪 Current store set: $storeId');
  }

  /// Réinitialise (par ex. à la déconnexion)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  /* ─────────── utilitaires ─────────── */
  /// Retourne tous les magasins du système
  static Future<List<Map<String, dynamic>>> fetchAllStores() async {
    final url = Uri.parse('$_baseUrl/stores');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['favorites'];
      return data.map((row) {
        return {
          'store_id': row['store_id'],
          'name': row['name'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch all stores');
    }
  }
  /// Retourne tous les magasins appartenant à `actorId` (owner)
  static Future<List<Map<String, dynamic>>> fetchStoresForOwner(
      int actorId,
      ) async {
    final url = Uri.parse('$_baseUrl/stores/?actor_id=$actorId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['favorites'];
      return data.map((row) {
        return {
          'store_id': row['store_id'],
          'name': row['name'],
        };
      }).toList();
    } else {
      throw Exception('Failed to fetch stores for owner');
    }
  }
}