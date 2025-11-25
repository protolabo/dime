import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../auth_viewmodel.dart';
import '../current_connected_account_vm.dart';

class SearchPageViewModel extends ChangeNotifier {
  final baseUrl = 'http://localhost:3001';
  final AuthViewModel auth;

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> availableStores = [];

  // Pour l'autocomplete de recherche
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;

  bool isLoading = false;
  String _currentFilter = 'All';

  // Store filter
  bool storeFilterEnabled = false;
  int? selectedStoreId;
  String? selectedStoreName;

  SearchPageViewModel({required this.auth}) {
    _loadProducts();
  }

  /* ──────────── SEARCH / AUTOCOMPLETE ──────────── */
  Future<void> query(String input) async {
    final q = input.trim();
    if (q.isEmpty) {
      searchResults = [];
      isSearching = false;
      notifyListeners();
      return;
    }

    isSearching = true;
    notifyListeners();

    try {
      // Recherche produits
      final prodResponse = await http.get(
        Uri.parse('$baseUrl/products?queryClient=${Uri.encodeComponent(q)}'),
      );
      final prodData = jsonDecode(prodResponse.body);
      final List prodList = (prodData['reviews'] as List).take(10).toList();

      // Recherche magasins
      final storeResponse = await http.get(
        Uri.parse('$baseUrl/stores?query=${Uri.encodeComponent(q)}'),
      );
      final storeData = jsonDecode(storeResponse.body);
      final List storeList = (storeData['favorites'] as List).take(10).toList();

      // Récupérer les favoris
      final actor = await CurrentActorService.getCurrentActor(auth: auth);
      final userId = actor.actorId;

      final favProdsResponse = await http.get(
        Uri.parse('$baseUrl/favorite-products?actor_id=$userId'),
      );
      final favProdsData = jsonDecode(favProdsResponse.body);
      final favProdIds = (favProdsData['favorites'] as List)
          .map<int>((e) => e['product_id'] as int)
          .toSet();

      final favStoresResponse = await http.get(
        Uri.parse('$baseUrl/favorite-stores?actor_id=$userId'),
      );
      final favStoresData = jsonDecode(favStoresResponse.body);
      final favStoreIds = (favStoresData['favoriteStores'] as List)
          .map<int>((e) => e['store_id'] as int)
          .toSet();

      searchResults = [
        ...prodList.map((p) => {
          'type': 'product',
          'id': p['product_id'],
          'title': p['name'],
          'subtitle': p['category'] ?? p['bar_code'] ?? '',
          'isFav': favProdIds.contains(p['product_id']),
        }),
        ...storeList.map((s) => {
          'type': 'store',
          'id': s['store_id'],
          'title': s['name'],
          'subtitle': '${s['city'] ?? ''} ${s['postal_code'] ?? ''} ${s['country'] ?? ''}',
          'isFav': favStoreIds.contains(s['store_id']),
        }),
      ];
    } catch (e) {
      log('Error searching: $e');
      searchResults = [];
    }

    isSearching = false;
    notifyListeners();
  }

  /* ──────────── TOGGLE FAVORITES IN SEARCH ──────────── */
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

      // Mettre à jour les résultats de recherche
      for (final item in searchResults) {
        if (item['type'] == 'product' && item['id'] == productId) {
          item['isFav'] = nowFav;
        }
      }

      // Mettre à jour les produits filtrés
      final index = filteredProducts.indexWhere((p) => p['id'] == productId);
      if (index != -1) {
        filteredProducts[index]['isFavorite'] = nowFav;
      }

      notifyListeners();
    } catch (e) {
      log('Error toggling favorite product: $e');
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

      // Mettre à jour les résultats de recherche
      for (final item in searchResults) {
        if (item['type'] == 'store' && item['id'] == storeId) {
          item['isFav'] = nowFav;
        }
      }

      notifyListeners();
    } catch (e) {
      log('Error toggling favorite store: $e');
    }
  }

  /* ──────────── LOAD ALL STORES ──────────── */
  Future<void> loadAllStores() async {
    try {
      final actor = await CurrentActorService.getCurrentActor(auth: auth);
      final userId = actor.actorId;

      // Récupérer tous les magasins
      final storesResponse = await http.get(
        Uri.parse('$baseUrl/stores'),
      );
      final storesData = jsonDecode(storesResponse.body);

      // Récupérer les favoris
      final favStoresResponse = await http.get(
        Uri.parse('$baseUrl/favorite-stores?actor_id=$userId'),
      );
      final favStoresData = jsonDecode(favStoresResponse.body);
      final favStoreIds = (favStoresData['favoriteStores'] as List)
          .map<int>((e) => e['store_id'] as int)
          .toSet();

      searchResults = [];
      if (storesData['favorites'] != null) {
        for (var store in storesData['favorites']) {
          searchResults.add({
            'type': 'store',
            'id': store['store_id'],
            'title': store['name'],
            'subtitle': '${store['city'] ?? ''} ${store['postal_code'] ?? ''} ${store['country'] ?? ''}',
            'isFav': favStoreIds.contains(store['store_id']),
          });
        }
      }

      notifyListeners();
    } catch (e) {
      log('Error loading all stores: $e');
    }
  }

  /* ──────────── LOAD PRODUCTS ──────────── */
  Future<void> _loadProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      final actor = await CurrentActorService.getCurrentActor(auth: auth);
      final userId = actor.actorId;

      final productsResponse = await http.get(
        Uri.parse('$baseUrl/products'),
      );
      final productsData = jsonDecode(productsResponse.body);

      final pricedProductsResponse = await http.get(
        Uri.parse('$baseUrl/priced-products'),
      );
      final pricedProductsData = jsonDecode(pricedProductsResponse.body);

      final storesResponse = await http.get(
        Uri.parse('$baseUrl/stores'),
      );
      final storesData = jsonDecode(storesResponse.body);

      final favoritesResponse = await http.get(
        Uri.parse('$baseUrl/favorite-products?actor_id=$userId'),
      );
      final favoritesData = jsonDecode(favoritesResponse.body);

      final Map<int, Map<String, dynamic>> priceMap = {};
      if (pricedProductsData['pricedProducts'] != null) {
        for (var priced in pricedProductsData['pricedProducts']) {
          final productId = priced['product_id'] as int;
          final amount = priced['amount'];

          if (!priceMap.containsKey(productId)) {
            priceMap[productId] = {
              'amount': _parsePrice(amount),
              'currency': priced['currency'] ?? 'USD',
              'store_id': priced['store_id'],
            };
          } else {
            final currentPrice = priceMap[productId]!['amount'];
            final newPrice = _parsePrice(amount);
            if (newPrice < currentPrice) {
              priceMap[productId] = {
                'amount': newPrice,
                'currency': priced['currency'] ?? 'USD',
                'store_id': priced['store_id'],
              };
            }
          }
        }
      }

      final favoriteProductIds = <int>{};
      if (favoritesData['favorites'] != null) {
        for (var fav in favoritesData['favorites']) {
          favoriteProductIds.add(fav['product_id'] as int);
        }
      }

      availableStores = [];
      if (storesData['favorites'] != null) {
        for (var store in storesData['favorites']) {
          availableStores.add({
            'id': store['store_id'],
            'name': store['name'] ?? 'Unknown Store',
            'city': store['city'],
            'country': store['country'],
          });
        }
      }

      _allProducts = [];
      if (productsData['reviews'] != null) {
        for (var product in productsData['reviews']) {
          final productId = product['product_id'] as int;
          final priceInfo = priceMap[productId];

          _allProducts.add({
            'id': productId,
            'name': product['name'] ?? 'Unknown Product',
            'price': priceInfo?['amount'] ?? 0.0,
            'currency': priceInfo?['currency'] ?? 'CAD',
            'store_id': priceInfo?['store_id'],
            'rating': _parseRating(product),
            'category': product['category'],
            'image': product['image_url'],
            'isFavorite': favoriteProductIds.contains(productId),
            'created_at': product['created_at'],
          });
        }
      }

      _allProducts.sort((a, b) {
        final aDate = a['created_at'] ?? '';
        final bDate = b['created_at'] ?? '';
        return bDate.toString().compareTo(aDate.toString());
      });

      filteredProducts = List.from(_allProducts);
      log('Loaded ${_allProducts.length} products');
      log('Loaded ${availableStores.length} stores');
    } catch (e) {
      log('Error loading products: $e');
      _allProducts = [];
      filteredProducts = [];
      availableStores = [];
    }

    isLoading = false;
    notifyListeners();
  }

  /* ──────────── FILTER PRODUCTS BY TYPE ──────────── */
  void filterProducts(String filter) {
    _currentFilter = filter;
    _applyFilters();
  }

  /* ──────────── FILTER BY STORE ──────────── */
  void filterByStore(int storeId, String storeName) {
    storeFilterEnabled = true;
    selectedStoreId = storeId;
    selectedStoreName = storeName;
    _applyFilters();
  }

  /* ──────────── CLEAR STORE FILTER ──────────── */
  void clearStoreFilter() {
    storeFilterEnabled = false;
    selectedStoreId = null;
    selectedStoreName = null;
    _applyFilters();
  }

  /* ──────────── APPLY ALL FILTERS ──────────── */
  void _applyFilters() {
    List<Map<String, dynamic>> temp = List.from(_allProducts);

    if (_currentFilter == 'Products') {
      temp = temp
          .where((p) => p['category']?.toLowerCase() != 'store')
          .toList();
    } else if (_currentFilter == 'Stores') {
      temp = temp
          .where((p) => p['category']?.toLowerCase() == 'store')
          .toList();
    }

    if (storeFilterEnabled && selectedStoreId != null) {
      temp = temp.where((p) => p['store_id'] == selectedStoreId).toList();
    }

    filteredProducts = temp;
    notifyListeners();
  }

  /* ──────────── TOGGLE FAVORITE ──────────── */
  Future<void> toggleFavorite(int productId) async {
    try {
      final actor = await CurrentActorService.getCurrentActor(auth: auth);
      final userId = actor.actorId;
      final userEmail = actor.email;

      final productIndex = _allProducts.indexWhere((p) => p['id'] == productId);
      if (productIndex == -1) return;

      final currentFavoriteStatus = _allProducts[productIndex]['isFavorite'] ?? false;
      final newFavoriteStatus = !currentFavoriteStatus;

      if (newFavoriteStatus) {
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

      _allProducts[productIndex]['isFavorite'] = newFavoriteStatus;

      final filteredIndex = filteredProducts.indexWhere((p) => p['id'] == productId);
      if (filteredIndex != -1) {
        filteredProducts[filteredIndex]['isFavorite'] = newFavoriteStatus;
      }

      notifyListeners();
    } catch (e) {
      log('Error toggling favorite: $e');
    }
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

  double _parseRating(Map product) {
    if (product['rating'] != null) {
      if (product['rating'] is double) return product['rating'];
      if (product['rating'] is int) return (product['rating'] as int).toDouble();
      if (product['rating'] is String) {
        return double.tryParse(product['rating']) ?? 5.0;
      }
    }
    return 5.0;
  }
}
