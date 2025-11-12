import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dime_flutter/vm/current_store.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../auth_viewmodel.dart';
import '../current_connected_account_vm.dart';

class ItemPageViewModel extends ChangeNotifier {
  final AuthViewModel auth;
  /* ───────────── ctor ───────────── */
  ItemPageViewModel({required this.productId, required this.auth}) {
    _init();
  }
  static const _baseUrl = 'http://localhost:3001';
  /* ──────────── fields ──────────── */
  final int productId;

  // Nombre max de magasins affichés dans la section
  static const int kStoresSectionLimit = 6;

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
    final response = await http.get(
      Uri.parse('$_baseUrl/products?product_id=$productId'));

    if (response.statusCode == 200){
    final json = jsonDecode(response.body);
    final data = (json['reviews'] as List).isNotEmpty ? json['reviews'][0] : null;
    if (data == null) throw Exception('Produit introuvable (id: $productId)');
    product = data;
    productName = data['name'] ?? '';
    barCode = (data['bar_code'] ?? '').toString();
    } else {
      throw Exception('Failed to load product');
    }
  }


  /* ─────────── magasin courant ─────────── */
  Future<void> _fetchCurrentStoreName() async {
    currentStoreName =
        (await CurrentStoreService.getCurrentStoreName()) ?? 'Inconnu';
  }

  /* ─────── favoris (stores) ─────── */
  Future<void> _fetchFavoriteStores() async {
    final actor = await CurrentActorService.getCurrentActor(auth: auth);
    final response = await http.get(
      Uri.parse('$_baseUrl/favorite-stores?actor_id=${actor.actorId}')
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = (json['favorites'] as List?) ?? [];
      favoriteStoreIds = data
          .map<int>((r) => r['store_id'] as int)
          .toList();
    } else {
      throw Exception('Erreur lors du chargement des magasins favoris');
    }
  }

  /* ─────── favoris (produit) ─────── */
   Future<void> _checkFavoriteProduct() async {
     final actor = await CurrentActorService.getCurrentActor(auth: auth);
     final response = await http.get(
       Uri.parse('$_baseUrl/favorite-products?actor_id=${actor.actorId}&product_id=$productId')
     );

     if (response.statusCode == 200) {
       final json = jsonDecode(response.body);
       final data = (json['favorites'] as List?) ?? [];
       isFavorite = data.isNotEmpty;
     } else {
       throw Exception('Erreur lors de la vérification du favori produit');
     }
   }

  Future<void> toggleFavorite() async {
    final actor = await CurrentActorService.getCurrentActor(auth: auth);

    if (isFavorite) {
      // Supprime le favori via l’API Express
      final response = await http.delete(
        Uri.parse('$_baseUrl/favorite-products/${actor.actorId}/$productId'),
      );
      if (response.statusCode == 200) {
        isFavorite = false;
      } else {
        throw Exception('Erreur lors de la suppression du favori');
      }
    } else {
      // Ajoute le favori via l’API Express
      final response = await http.post(
        Uri.parse('$_baseUrl/favorite-products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'actor_id': actor.actorId,
          'product_id': productId,
          'created_by': actor.actorId.toString(),
        }),
      );
      if (response.statusCode == 201) {
        isFavorite = true;
      } else {
        throw Exception('Erreur lors de l\'ajout du favori');
      }
    }
    notifyListeners();
  }


  /* ─────── prix & magasins ─────── */
  Future<void> _fetchStoresWithPrices() async {
    try {
      // 1) Récupère les produits avec le même code-barre
      final productRes = await http.get(
        Uri.parse('$_baseUrl/products?bar_code=$barCode'),
      );
      if (productRes.statusCode != 200) throw Exception('Erreur produits');
      final productJson = jsonDecode(productRes.body);
      final productList = (productJson['reviews'] as List?) ?? [];
      final productIds = productList.map<int>((r) => r['product_id'] as int).toList();
      if (productIds.isEmpty) {
        storesWithPrice = [];
        return;
      }

      // 2) Récupère les prix par magasin pour ces produits
      final productIdParams = productIds.map((id) => 'product_id=$id').join('&');
      final pricedRes = await http.get(
        Uri.parse('$_baseUrl/priced-products?$productIdParams'),
      );
      if (pricedRes.statusCode != 200) throw Exception('Erreur prix');
      final pricedJson = jsonDecode(pricedRes.body);
      final pricedRows = (pricedJson['pricedProducts'] as List?) ?? [];
      if (pricedRows.isEmpty) {
        storesWithPrice = [];
        return;
      }

      // 3) Récupère les noms des magasins
      final storeIds = pricedRows.map<int>((r) => r['store_id'] as int).toSet().toList();
      final storeIdParams = storeIds.map((id) => 'store_id=$id').join('&');
      final storeRes = await http.get(
        Uri.parse('$_baseUrl/stores?$storeIdParams'),
      );
      if (storeRes.statusCode != 200) throw Exception('Erreur magasins');
      final storeJson = jsonDecode(storeRes.body);
      final storeRows = (storeJson['favorites'] as List?) ?? [];
      final storeName = {
        for (final r in storeRows) r['store_id'] as int: r['name'] as String,
      };

      // 4) Récupère les promotions actives
      final promoIds = pricedRows
          .where((r) => r['promotion_id'] != null)
          .map<int>((r) => r['promotion_id'] as int)
          .toSet()
          .toList();
      Map<int, Map<String, dynamic>> promoMap = {};
      if (promoIds.isNotEmpty) {
        final promoIdParams = promoIds.map((id) => 'promotion_id=$id').join('&');
        final promoRes = await http.get(
          Uri.parse('$_baseUrl/promotions?$promoIdParams'),
        );
        if (promoRes.statusCode == 200) {
          final promoJson = jsonDecode(promoRes.body);
          final promos = (promoJson['reviews'] as List?) ?? [];
          final now = DateTime.now();
          for (final p in promos) {
            final start = DateTime.parse(p['start_date']);
            final end = DateTime.parse(p['end_date'] ?? '9999-12-31');
            if (start.isBefore(now) && end.isAfter(now)) {
              promoMap[p['promotion_id'] as int] = p;
            }
          }
        }
      }

      // 5) Modèle final pour la vue
      storesWithPrice = pricedRows.map<Map<String, dynamic>>((row) {
        final promo = promoMap[row['promotion_id']];
        return {
          'store_id': row['store_id'],
          'product_id': row['product_id'],
          'store_name': storeName[row['store_id']] ?? 'Store ${row['store_id']}',
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


  /* ─────── Liste triée + limitée pour l’UI ─────── */
  List<Map<String, dynamic>> get storesForSection {
    if (storesWithPrice.isEmpty) return [];
    final favSet = favoriteStoreIds.toSet();

    final fav = <Map<String, dynamic>>[];
    final nonFav = <Map<String, dynamic>>[];

    for (final s in storesWithPrice) {
      final id = s['store_id'] as int?;
      if (id == null) continue;
      (favSet.contains(id) ? fav : nonFav).add(s);
    }

    int byPrice(a, b) {
      final pa = (a['price'] as num?)?.toDouble() ?? double.infinity;
      final pb = (b['price'] as num?)?.toDouble() ?? double.infinity;
      return pa.compareTo(pb);
    }

    fav.sort(byPrice);
    nonFav.sort(byPrice);

    final merged = <Map<String, dynamic>>[...fav, ...nonFav];
    return merged.length <= kStoresSectionLimit
        ? merged
        : merged.sublist(0, kStoresSectionLimit);
  }
}
