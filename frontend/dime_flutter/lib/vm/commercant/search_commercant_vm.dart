import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dime_flutter/vm/current_store.dart';

class ProductResult {
  final int productId;
  final String name;
  final String? imageUrl;
  final String? barCode;
  final num? amount;
  final String? currency;
  final String? pricingUnit;

  ProductResult({
    required this.productId,
    required this.name,
    this.imageUrl,
    this.barCode,
    this.amount,
    this.currency,
    this.pricingUnit,
  });
}

class ShelfResult {
  final int shelfId;
  final String name;
  final String? location;

  ShelfResult({
    required this.shelfId,
    required this.name,
    this.location,
  });
}

class SearchCommercantVM extends ChangeNotifier {
  static const String apiBaseUrl = 'http://localhost:3001';

  final TextEditingController searchController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _storeId;
  int? get storeId => _storeId;

  Timer? _debounce;
   String get lastQuery => _lastQuery;

  List<ProductResult> _products = [];
  List<ProductResult> get products => _products;

  List<ShelfResult> _shelves = [];
  List<ShelfResult> get shelves => _shelves;

  String _lastQuery = '';

  Future<void> bootstrap() async {
    _storeId = await CurrentStoreService.getCurrentStoreId();
    notifyListeners();
  }

  void onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      search(q);
    });
  }

  Future<void> search(String query) async {
    _lastQuery = query;

    final sid = _storeId;
    if (sid == null) {
      _products = [];
      _shelves = [];
      notifyListeners();
      return;
    }

    final q = query.trim();
    if (q.isEmpty) {
      _products = [];
      _shelves = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 1) Recherche produits (par nom ou code-barres)
      //print('🔍 Recherche produits pour "$q" dans store $sid');
      final prodResponse = await http.get(
        Uri.parse('$apiBaseUrl/products?queryCommercant=${Uri.encodeComponent(q)}')
      );

      if (prodResponse.statusCode != 200) {
        throw Exception('Erreur produits: ${prodResponse.statusCode}');
      }

      final prodData = jsonDecode(prodResponse.body);
      final prodList = (prodData['reviews'] as List?) ?? [];
      final productIds = prodList.map((e) => e['product_id'] as int).toList();

      final productById = <int, Map<String, dynamic>>{
        for (final e in prodList) (e['product_id'] as int): (e as Map<String, dynamic>)
      };

      // 2) Récupère les prix pour ce store
      List<dynamic> pricedList = [];
      if (productIds.isNotEmpty) {
        final pricedResponse = await http.get(
          Uri.parse('$apiBaseUrl/priced-products?store_id=$sid'));

        if (pricedResponse.statusCode == 200) {
          final pricedData = jsonDecode(pricedResponse.body);
          pricedList = (pricedData['pricedProducts'] as List?) ?? [];
        }
      }

      final pricedByPid = <int, Map<String, dynamic>>{};
      for (final r in pricedList) {
        final pid = r['product_id'] as int;
        if (productIds.contains(pid)) {
          pricedByPid[pid] = r as Map<String, dynamic>;
        }
      }

      final productResults = <ProductResult>[];
      for (final pid in productIds) {
        final priced = pricedByPid[pid];
        if (priced == null) continue; // pas vendu dans ce store

        final p = productById[pid]!;
        productResults.add(
          ProductResult(
            productId: pid,
            name: (p['name'] as String?) ?? 'Unnamed',
            imageUrl: p['image_url'] as String?,
            barCode: p['bar_code'] as String?,
            amount: priced['amount'] as num?,
            currency: priced['currency'] as String?,
            pricingUnit: priced['pricing_unit'] as String?,
          ),
        );
      }

      // 3) Recherche étagères (par nom ou location)
      final shelfResponse = await http.get(
        Uri.parse('$apiBaseUrl/shelves?store_id=$sid&queryCommercant=${Uri.encodeComponent(q)}')
      );

      List<ShelfResult> shelfResults = [];
      if (shelfResponse.statusCode == 200) {
        final shelfData = jsonDecode(shelfResponse.body);
        final shelfList = (shelfData['reviews'] as List?) ?? [];
        shelfResults = shelfList.map((s) {
          return ShelfResult(
            shelfId: s['shelf_id'] as int,
            name: (s['name'] as String?) ?? 'Unnamed shelf',
            location: s['location'] as String?,
          );
        }).toList();
      }

      productResults.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      shelfResults.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      _products = productResults;
      _shelves = shelfResults;
    } catch (e) {
      _products = [];
      _shelves = [];
      //print('Erreur de recherche: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
