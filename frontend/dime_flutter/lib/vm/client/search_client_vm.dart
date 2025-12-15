import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../auth_viewmodel.dart';
import '../current_connected_account_vm.dart';

class SearchPageViewModel extends ChangeNotifier {
  final baseUrl = dotenv.env['BACKEND_API_URL'] ?? '';
  final AuthViewModel auth;

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> availableStores = [];

  // For search/autocomplete
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;

  bool isLoading = false;
  String _currentFilter = 'Products';

  // Store filter
  bool storeFilterEnabled = false;
  int? selectedStoreId;
  String? selectedStoreName;

  SearchPageViewModel({required this.auth}) {
    _loadProducts();
  }

/* ──────────── SEARCH / AUTOCOMPLETE ──────────── */
  Future<void> query(String input, String filter) async {
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
      // Search products
      final prodResponse = await http.get(
        Uri.parse('$baseUrl/products?queryClient=${Uri.encodeComponent(q)}'),
      );
      final prodData = jsonDecode(prodResponse.body);
      final List prodList = (prodData['reviews'] as List).take(10).toList();

      // Search stores
      final storeResponse = await http.get(
        Uri.parse('$baseUrl/stores?queryClient=${Uri.encodeComponent(q)}'),
      );
      final storeData = jsonDecode(storeResponse.body);
      final List storeList = (storeData['favorites'] as List).take(10).toList();

      // Get favorites
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

      // Get priced products to get store_id for each product
      final pricedProductsResponse = await http.get(
        Uri.parse('$baseUrl/priced-products'),
      );
      final pricedProductsData = jsonDecode(pricedProductsResponse.body);

      // Create map of product_id -> store_id
      final Map<int, int> productStoreMap = {};
      if (pricedProductsData['pricedProducts'] != null) {
        for (var priced in pricedProductsData['pricedProducts']) {
          final productId = priced['product_id'] as int;
          final storeId = priced['store_id'] as int?;
          if (storeId != null) {
            productStoreMap[productId] = storeId;
          }
        }
      }

      searchResults = [
        ...prodList.map((p) {
          final productId = p['product_id'] as int;
          return {
            'type': 'product',
            'id': productId,
            'title': p['name'],
            'subtitle': "barcode : " +p['bar_code'] ?? '',
            'isFav': favProdIds.contains(productId),
            'store_id': productStoreMap[productId],
            "image_url": p['image_url'] ?? '',
          };
        }),
        ...storeList.map((s) => {
          'type': 'store',
          'id': s['store_id'],
          'title': s['name'],
          'subtitle': '${s['city'] ?? ''} ${s['postal_code'] ?? ''} ${s['country'] ?? ''}',
          'isFav': favStoreIds.contains(s['store_id']),
          "image_url": s['logo_url'] ?? '',
        }),
      ];

      // Apply filter by type (Products/Stores)
      if (filter == 'Products') {
        searchResults = searchResults.where((item) => item['type'] == 'product').toList();
      } else if (filter == 'Stores') {
        searchResults = searchResults.where((item) => item['type'] == 'store').toList();
      }

      // Apply store filter if enabled
      if (storeFilterEnabled && selectedStoreId != null && filter == 'Products') {
        searchResults = searchResults.where((item) {
          if (item['type'] != 'product') return true;
          return item['store_id'] == selectedStoreId;
        }).toList();
      }
    } catch (e) {
      log('❌ Error searching: $e');
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

      // Update search results
      for (final item in searchResults) {
        if (item['type'] == 'product' && item['id'] == productId) {
          item['isFav'] = nowFav;
        }
      }

      // Update filtered products
      final index = filteredProducts.indexWhere((p) => p['id'] == productId);
      if (index != -1) {
        filteredProducts[index]['isFavorite'] = nowFav;
      }

      // Update all products
      final allIndex = _allProducts.indexWhere((p) => p['id'] == productId);
      if (allIndex != -1) {
        _allProducts[allIndex]['isFavorite'] = nowFav;
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error toggling favorite product: $e');
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

      // Update search results
      for (final item in searchResults) {
        if (item['type'] == 'store' && item['id'] == storeId) {
          item['isFav'] = nowFav;
        }
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error toggling favorite store: $e');
    }
  }

  /* ──────────── SHOW ALL STORES (called when Stores filter is clicked) ──────────── */
  void showAllStores() {
    _currentFilter = 'Stores';
    notifyListeners();
  }

  /* ──────────── LOAD PRODUCTS ──────────── */
  Future<void> _loadProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      final actor = await CurrentActorService.getCurrentActor(auth: auth);
      final userId = actor.actorId;

      // Fetch products
      final productsResponse = await http.get(
        Uri.parse('$baseUrl/products'),
      );
      final productsData = jsonDecode(productsResponse.body);

      // Fetch priced products (to get prices)
      final pricedProductsResponse = await http.get(
        Uri.parse('$baseUrl/priced-products'),
      );
      final pricedProductsData = jsonDecode(pricedProductsResponse.body);

      // Fetch stores
      final storesResponse = await http.get(
        Uri.parse('$baseUrl/stores'),
      );
      final storesData = jsonDecode(storesResponse.body);

      // Fetch favorite products
      final favoritesResponse = await http.get(
        Uri.parse('$baseUrl/favorite-products?actor_id=$userId'),
      );
      final favoritesData = jsonDecode(favoritesResponse.body);

      // Create a map of product_id -> price info
      final Map<int, Map<String, dynamic>> priceMap = {};
      if (pricedProductsData['pricedProducts'] != null) {
        for (var priced in pricedProductsData['pricedProducts']) {
          final productId = priced['product_id'] as int;
          final amount = priced['amount'];

          // Store the lowest price or first price found
          if (!priceMap.containsKey(productId)) {
            priceMap[productId] = {
              'amount': _parsePrice(amount),
              'currency': priced['currency'] ?? 'CAD',
              'store_id': priced['store_id'],
            };
          } else {
            // Keep the lowest price
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

      // Create a set of favorite product IDs
      final favoriteProductIds = <int>{};
      if (favoritesData['favorites'] != null) {
        for (var fav in favoritesData['favorites']) {
          favoriteProductIds.add(fav['product_id'] as int);
        }
      }

      // Process stores
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

      // Map products with prices and favorite status
      _allProducts = [];
      if (productsData['reviews'] != null) {
        for (var product in productsData['reviews']) {
          final productId = product['product_id'] as int;
          final priceInfo = priceMap[productId];

          _allProducts.add({
            'id': productId,
            'name': product['name'] ?? 'Unknown Product',
            'price': priceInfo?['amount'] ?? null,
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

      // Sort by most recent (if created_at exists)
      // _allProducts.sort((a, b) {
      //   final aDate = a['created_at'] ?? '';
      //   final bDate = b['created_at'] ?? '';
      //   return bDate.toString().compareTo(aDate.toString());
      // });
      _allProducts.shuffle();

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

    // Apply type filter (but not for Stores view, which shows stores list)
    if (_currentFilter == 'Products') {
      temp = temp
          .where((p) => p['category']?.toLowerCase() != 'store')
          .toList();
    }
    // For 'Stores', we don't filter products - the UI will show stores list instead

    // Apply store filter
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

      // Find the product in all lists
      final productIndex = _allProducts.indexWhere((p) => p['id'] == productId);
      if (productIndex == -1) return;

      final currentFavoriteStatus = _allProducts[productIndex]['isFavorite'] ?? false;
      final newFavoriteStatus = !currentFavoriteStatus;

      if (newFavoriteStatus) {
        // Add to favorites
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
        // Remove from favorites
        await http.delete(
          Uri.parse('$baseUrl/favorite-products/$userId/$productId'),
        );
      }

      // Update local state
      _allProducts[productIndex]['isFavorite'] = newFavoriteStatus;

      // Update filtered products if it contains this product
      final filteredIndex = filteredProducts.indexWhere((p) => p['id'] == productId);
      if (filteredIndex != -1) {
        filteredProducts[filteredIndex]['isFavorite'] = newFavoriteStatus;
      }

      notifyListeners();
    } catch (e) {
      log('❌ Error toggling favorite: $e');
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
    // Try to get rating from various possible fields
    if (product['rating'] != null) {
      if (product['rating'] is double) return product['rating'];
      if (product['rating'] is int) return (product['rating'] as int).toDouble();
      if (product['rating'] is String) {
        return double.tryParse(product['rating']) ?? 5.0;
      }
    }
    return 5.0; // Default rating
  }
}