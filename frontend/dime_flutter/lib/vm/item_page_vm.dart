import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dime_flutter/vm/current_store.dart';

import 'current_connected_account_vm.dart';

class ItemPageViewModel extends ChangeNotifier {
  /* ───────────── ctor ───────────── */
  ItemPageViewModel({required this.productId}) {
    _init();
  }

  /* ──────────── fields ──────────── */
  final int productId;

  bool isLoading = true;
  String? error;

  // Produit
  Map<String, dynamic>? product;
  String productName = '';
  String barCode = '';

  // Magasin courant
  String currentStoreName = '';

  // Favoris produit
  bool isFavorite = false;

  // Prix par magasin
  List<Map<String, dynamic>> stores = []; // [{store_id, store_name, price}]
  List<Map<String, dynamic>> storesWithPrice = []; // alias si besoin
  List<int> favoriteStoreIds = [];

  // Prix affiché sous le cœur (pour CE product_id)
  double? minPrice;

  /* ──────────── init ──────────── */
  Future<void> _init() async {
    try {
      await _fetchProduct();
      await _fetchCurrentStoreName();
      await _fetchFavoriteStores();
      await _checkFavoriteProduct();
      await _fetchStoresWithPrices();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  /* ─────────── produit ─────────── */
  Future<void> _fetchProduct() async {
    final supabase = Supabase.instance.client;

    final data = await supabase
        .from('product')
        .select('product_id, name, bar_code')
        .eq('product_id', productId)
        .maybeSingle();

    if (data == null) throw 'Produit introuvable (#$productId)';

    product = data;
    productName = data['name'] as String? ?? '';
    barCode = (data['bar_code'] ?? '').toString();
  }

  /* ─────────── magasin courant ─────────── */
  Future<void> _fetchCurrentStoreName() async {
    currentStoreName =
        (await CurrentStoreService.getCurrentStoreName()) ?? 'Inconnu';
  }

  /* ─────── favoris (stores) ─────── */
  Future<void> _fetchFavoriteStores() async {
    final supabase = Supabase.instance.client;
    final actor = await CurrentActorService.getCurrentActor();

    final rows = await supabase
        .from('favorite_store')
        .select('store_id')
        .eq('actor_id', actor.actorId);

    favoriteStoreIds = rows.map<int>((r) => r['store_id'] as int).toList();
  }

  /* ─────── favoris (produit) ─────── */
  Future<void> _checkFavoriteProduct() async {
    final supabase = Supabase.instance.client;
    final actor = await CurrentActorService.getCurrentActor();

    final fav = await supabase
        .from('favorite_product')
        .select('actor_id')
        .eq('actor_id', actor.actorId)
        .eq('product_id', productId)
        .maybeSingle();

    isFavorite = fav != null;
  }

  Future<void> toggleFavorite() async {
    final supabase = Supabase.instance.client;
    final actor = await CurrentActorService.getCurrentActor();

    if (isFavorite) {
      await supabase
          .from('favorite_product')
          .delete()
          .eq('actor_id', actor.actorId)
          .eq('product_id', productId);
      isFavorite = false;
    } else {
      await supabase.from('favorite_product').insert({
        'actor_id': actor.actorId,
        'product_id': productId,
        'created_by': actor.actorId.toString(),
      });
      isFavorite = true;
    }
    notifyListeners();
  }

  /* ─────── prix & magasins ─────── */
  Future<void> _fetchStoresWithPrices() async {
    final supabase = Supabase.instance.client;

    try {
      // 1) Produits avec le même code-barre
      final idRows = await supabase
          .from('product')
          .select('product_id')
          .eq('bar_code', barCode);

      final productIds = idRows
          .map<int>((r) => r['product_id'] as int)
          .toList();
      if (productIds.isEmpty) {
        storesWithPrice = [];
        return;
      }

      // 2) Prix + promo éventuelle (on garde product_id)
      final pricedRows = await supabase
          .from('priced_product')
          .select('store_id, amount, promotion_id, product_id')
          .inFilter('product_id', productIds);

      if (pricedRows.isEmpty) {
        storesWithPrice = [];
        return;
      }

      // 3) Noms des magasins
      final storeIds = pricedRows
          .map<int>((r) => r['store_id'] as int)
          .toSet()
          .toList();

      final storeRows = await supabase
          .from('store')
          .select('store_id, name')
          .inFilter('store_id', storeIds);

      final storeName = {
        for (final r in storeRows) r['store_id'] as int: r['name'] as String,
      };

      // 4) Infos promo (actives)
      final promoIds = pricedRows
          .where((r) => r['promotion_id'] != null)
          .map<int>((r) => r['promotion_id'] as int)
          .toSet()
          .toList();

      Map<int, Map<String, dynamic>> promoMap = {};
      if (promoIds.isNotEmpty) {
        final promos = await supabase
            .from('promotion')
            .select('promotion_id, title, start_date, end_date')
            .inFilter('promotion_id', promoIds);

        final now = DateTime.now();
        for (final p in promos) {
          final start = DateTime.parse(p['start_date']);
          final end = DateTime.parse(p['end_date'] ?? '9999-12-31');
          if (start.isBefore(now) && end.isAfter(now)) {
            promoMap[p['promotion_id'] as int] = p;
          }
        }
      }

      // 5) Modèle final pour la vue
      storesWithPrice = pricedRows.map<Map<String, dynamic>>((row) {
        final promo = promoMap[row['promotion_id']];
        return {
          'store_id': row['store_id'],
          'product_id': row['product_id'], // pour filtrer plus tard
          'store_name':
              storeName[row['store_id']] ?? 'Store ${row['store_id']}',
          'price': row['amount'],
          'isPromo': promo != null,
          'promoTitle': promo?['title'],
        };
      }).toList();

      // 6) Prix à afficher (uniquement ce productId)
      final sameProductPrices = storesWithPrice
          .where((e) => e['product_id'] == productId)
          .map<double>((e) => (e['price'] as num).toDouble())
          .toList();

      if (sameProductPrices.isNotEmpty) {
        minPrice = sameProductPrices.reduce((a, b) => a < b ? a : b);
      }
    } catch (e) {
      error = e.toString();
    }

    notifyListeners();
  }
}
