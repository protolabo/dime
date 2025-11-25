import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../auth_viewmodel.dart';
import '../current_connected_account_vm.dart';

/// View-Model pour la page `FavoriteMenuPage`
class FavoriteMenuVM extends ChangeNotifier {
  final AuthViewModel auth;
  final baseUrl = 'http://localhost:3001';

  FavoriteMenuVM({required this.auth});

  /* ────────────── état interne ────────────── */
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> favoriteProducts = [];
  List<Map<String, dynamic>> favoriteStores = [];

  final Map<int, bool> favoriteProductStates = {};
  final Map<int, bool> favoriteStoreStates = {};

  /* ───────────── getters publics ───────────── */
  bool get loading => _loading;
  String? get error => _error;

  /* ───────────── initialisation ───────────── */
  Future<void> init() async {
    _loading = true;
    notifyListeners();

    try {
      final actor = await CurrentActorService.getCurrentActor(auth: auth);
      final userId = actor.actorId;

      // Fetch products
      final productsResponse = await http.get(
        Uri.parse('$baseUrl/products'),
      );
      final productsData = jsonDecode(productsResponse.body);


      // Fetch stores
      final storesResponse = await http.get(
        Uri.parse('$baseUrl/stores'),
      );
      final storesData = jsonDecode(storesResponse.body);

      // Fetch favorite products
      final favProdsResponse = await http.get(
        Uri.parse('$baseUrl/favorite-products?actor_id=$userId'),
      );
      final favProdsData = jsonDecode(favProdsResponse.body);

      // Fetch favorite stores
      final favStoresResponse = await http.get(
        Uri.parse('$baseUrl/favorite-stores?actor_id=$userId'),
      );
      final favStoresData = jsonDecode(favStoresResponse.body);

      // Fetch priced products to get prices
      final pricedProductsResponse = await http.get(
        Uri.parse('$baseUrl/priced-products'),
      );
      final pricedProductsData = jsonDecode(pricedProductsResponse.body);


      final Map<int, Map<String, dynamic>> productInfoMap = {};
      if (productsData['reviews'] != null) {
        for (var product in productsData['reviews']) {
          final productId = product['product_id'] as int;
          productInfoMap[productId] = {
            'name': product['name'] ?? 'Unknown Product',
            'image': product['image_url'],
            'rating': 5.0,
            'category': product['category'],
          };
        }
      }

      final Map<int, Map<String, dynamic>> storeInfoMap = {};
      if (storesData['favorites'] != null) {
        for (var store in storesData['favorites']) {
          final storeId = store['store_id'] as int;
          storeInfoMap[storeId] = {
            'name': store['name'],
            'address': store['address'],
            'city': store['city'],
            'country': store['country'],
            'postal_code': store['postal_code']
          };
        }
      }

      // Create a map of product_id -> price info
      final Map<int, Map<String, dynamic>> priceMap = {};
      if (pricedProductsData['pricedProducts'] != null) {
        for (var priced in pricedProductsData['pricedProducts']) {
          final productId = priced['product_id'] as int;
          final amount = priced['amount'];


          if (!priceMap.containsKey(productId)) {
            priceMap[productId] = {
              'amount': _parsePrice(amount),
              'currency': priced['currency'] ?? 'CAD',
              'store_id': priced['store_id'],
            };
          } else {
            final currentPrice = priceMap[productId]!['amount'];
            final newPrice = _parsePrice(amount);
            if (newPrice < currentPrice) {
              priceMap[productId] = {
                'amount': newPrice,
                'currency': priced['currency'] ?? 'CAD',
                'store_id': priced['store_id'],
              };
            }
          }
        }
      }


      // Process favorite products
      favoriteProducts.clear();
      favoriteProductStates.clear();

      if (favProdsData['favorites'] != null) {
        for (var fav in favProdsData['favorites']) {
          final productId = fav['product_id'] as int;
          final priceInfo = priceMap[productId];
          final productInfo = productInfoMap[productId];

          favoriteProducts.add({
            'id': productId,
            'name': productInfo?['name'] ?? 'Unknown Product',
            'price': priceInfo?['amount'] ?? 0.0,
            'currency': priceInfo?['currency'] ?? 'CAD',
            'store_id': priceInfo?['store_id'],
            'rating': 5.0,
            'image': productInfo?['image'] ?? '',
            'isFavorite': true,
          });

          favoriteProductStates[productId] = true;
        }
      }

      // Process favorite stores
      favoriteStores.clear();
      favoriteStoreStates.clear();

      if (favStoresData['favoriteStores'] != null) {
        for (var fav in favStoresData['favoriteStores']) {
          final storeId = fav['store_id'] as int;
          final storeInfo = storeInfoMap[storeId];
          favoriteStores.add({
            'id': storeId,
            'name': storeInfo?['name'] ?? 'Unknown Store',
            'address': storeInfo?['address'] ?? '',
            'city': storeInfo?['city'] ?? '',
            'country': storeInfo?['country'] ?? '',
            'postal_code': storeInfo?['postal_code'] ?? '',
            'isFavorite': true,
          });

          favoriteStoreStates[storeId] = true;
        }
      }

      log('Loaded ${favoriteProducts.length} favorite products');
      log('Loaded ${favoriteStores.length} favorite stores');

      _loading = false;
      notifyListeners();
    } catch (e) {
      log('Error loading favorites: $e');
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  /* ─────────── toggle favoris (UI) ─────────── */
  void toggleProduct(int id, bool fav) {
    favoriteProductStates[id] = fav;

    // Update the product in the list
    final index = favoriteProducts.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      favoriteProducts[index]['isFavorite'] = fav;
    }

    notifyListeners();
  }

  void toggleStore(int id, bool fav) {
    favoriteStoreStates[id] = fav;

    // Update the store in the list
    final index = favoriteStores.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      favoriteStores[index]['isFavorite'] = fav;
    }

    notifyListeners();
  }

  /* ─────────── toggle favoris (API) ─────────── */
  Future<void> toggleFavoriteProduct(int productId, bool nowFav) async {
    try {
      final actor = await CurrentActorService.getCurrentActor(auth: auth);
      final userId = actor.actorId;
      final userEmail = actor.email;

      if (nowFav) {
        await http.post(
          Uri.parse('$baseUrl/favorite-products'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'actor_id': userId,
            'product_id': productId,
            'created_by': userEmail,
          }),
        );
      } else {
        await http.delete(
          Uri.parse('$baseUrl/favorite-products/$userId/$productId'),
        );
      }

      toggleProduct(productId, nowFav);

      // If unfavoriting, remove from list after a short delay
      if (!nowFav) {
        await Future.delayed(const Duration(milliseconds: 300));
        favoriteProducts.removeWhere((p) => p['id'] == productId);
        favoriteProductStates.remove(productId);
        notifyListeners();
      }
    } catch (e) {
      log('Error toggling favorite product: $e');
      _error = 'Error updating favorite: $e';
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteStore(int storeId, bool nowFav) async {
    try {
      final actor = await CurrentActorService.getCurrentActor(auth: auth);
      final userId = actor.actorId;
      final userEmail = actor.email;

      if (nowFav) {
        await http.post(
          Uri.parse('$baseUrl/favorite-stores'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'actor_id': userId,
            'store_id': storeId,
            'created_by': userEmail,
          }),
        );
      } else {
        await http.delete(
          Uri.parse('$baseUrl/favorite-stores/$userId/$storeId'),
        );
      }

      toggleStore(storeId, nowFav);

      if (!nowFav) {
        await Future.delayed(const Duration(milliseconds: 300));
        favoriteStores.removeWhere((s) => s['id'] == storeId);
        favoriteStoreStates.remove(storeId);
        notifyListeners();
      }
    } catch (e) {
      log('Error toggling favorite store: $e');
      _error = 'Error updating favorite: $e';
      notifyListeners();
    }
  }

  /* ───────────── persistance BD (legacy - now handled by toggleFavorite methods) ───────────── */
  Future<void> persistDeletions() async {
    // This method is kept for backward compatibility but the actual
    // deletion is now handled immediately in toggleFavoriteProduct/Store
    log('Favorites already persisted');
  }

  /* ──────────── HELPER METHODS ──────────── */
  double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }
}