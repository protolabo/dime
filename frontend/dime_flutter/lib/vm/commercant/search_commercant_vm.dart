import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final supabase = Supabase.instance.client;

  final TextEditingController searchController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _storeId;
  int? get storeId => _storeId;

  Timer? _debounce;

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

    final sid = _storeId; // <- promotion en locale pour éviter int?
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
      final pattern = '%$q%';

      // 1) Produits qui matchent par nom ou code-barres
      final prodRows = await supabase
          .from('product')
          .select('product_id, name, image_url, bar_code')
          .or('name.ilike.$pattern,bar_code.ilike.$pattern');

      final list = (prodRows as List<dynamic>);
      final productIds = list.map((e) => e['product_id'] as int).toList();

      final productById = <int, Map<String, dynamic>>{
        for (final e in list) (e['product_id'] as int): (e as Map<String, dynamic>)
      };

      List<dynamic> pricedRows = [];
      if (productIds.isNotEmpty) {
        pricedRows = await supabase
            .from('priced_product')
            .select('product_id, amount, currency, pricing_unit')
            .eq('store_id', sid) // <- utilise la locale non-null
            .inFilter('product_id', productIds);
      }

      final pricedByPid = <int, Map<String, dynamic>>{};
      for (final r in pricedRows) {
        pricedByPid[r['product_id'] as int] = (r as Map<String, dynamic>);
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

      // 2) Étagères du store, filtrées par nom/location
      final shelfRows = await supabase
          .from('shelf')
          .select('shelf_id, name, location')
          .eq('store_id', sid) // <- utilise la locale non-null
          .or('name.ilike.$pattern,location.ilike.$pattern');

      final shelfResults = (shelfRows as List<dynamic>).map((s) {
        return ShelfResult(
          shelfId: s['shelf_id'] as int,
          name: (s['name'] as String?) ?? 'Unnamed shelf',
          location: s['location'] as String?,
        );
      }).toList();

      productResults.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      shelfResults.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      _products = productResults;
      _shelves = shelfResults;
    } catch (e) {
      _products = [];
      _shelves = [];
      // print(e);
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
