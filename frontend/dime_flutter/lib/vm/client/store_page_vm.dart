// dart
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dime_flutter/vm/current_connected_account_vm.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../auth_viewmodel.dart';

class StorePageVM extends ChangeNotifier {
  final AuthViewModel auth;
  final baseUrl = 'http://localhost:3001';
  /* ───────── infos magasin ───────── */
  String? storeName;
  String? address;
  bool   isStoreFavorite = false;

  StorePageVM({required this.auth});

  /* ───────── état UI ───────── */
  bool   isLoading = true;
  String? error;

  /* ───────── recommandations ───────── */
  List<Map<String, dynamic>> recos = [];

  /// Charge toutes les données nécessaires à l’écran.
  Future<void> load(int storeId) async {
    try {
      final actor = await CurrentActorService.getCurrentActor(auth: auth);
      final int userId = actor.actorId;

      // 1. Détails du magasin
      final storeResponse = await http.get(Uri.parse('$baseUrl/stores?store_id=$storeId'));
      if (storeResponse.statusCode != 200) {
        error = 'Magasin introuvable';
        isLoading = false;
        notifyListeners();
        return;
      }
      final storeData = jsonDecode(storeResponse.body);
      final favorites = storeData['favorites'];
      final s = (favorites is List && favorites.isNotEmpty) ? favorites[0] : null;
      if (s == null) {
        error = 'Magasin introuvable';
        isLoading = false;
        notifyListeners();
        return;
      }

      storeName = s['name'] as String?;
      address = [
        if ((s['address'] ?? '').toString().isNotEmpty) s['address'],
        if ((s['city'] ?? '').toString().isNotEmpty)    s['city'],
        if ((s['postal_code'] ?? '').toString().isNotEmpty) s['postal_code'],
      ].whereType<String>().join(', ');

      // 2. Est-ce un favori ?
      final favStoreResponse = await http.get(Uri.parse('$baseUrl/favorite-stores?actor_id=$userId&store_id=$storeId'));
      final favStoreData = jsonDecode(favStoreResponse.body);
      isStoreFavorite = (favStoreData['favoriteStores'] as List).isNotEmpty;

      // 3. Produits favoris
      final favProdResponse = await http.get(Uri.parse('$baseUrl/favorite-products?actor_id=$userId'));
      final favProdData = jsonDecode(favProdResponse.body);
      final favIds = (favProdData['favorites'] as List)
          .map<int>((e) => e['product_id'] as int)
          .toSet();

      // 4. Barcodes des favoris
      Set<String> favBarcodes = {};
      if (favIds.isNotEmpty) {
        final favtIdParams = favIds.map((id) => 'product_id=$id').join('&');
        final allFavsResponse = await http.get(Uri.parse('$baseUrl/products?$favtIdParams'));
        final allFavsData = jsonDecode(allFavsResponse.body);
        favBarcodes = (allFavsData['reviews'] as List)
            .where((r) => favIds.contains(r['product_id']))
            .map<String>((r) => r['bar_code'] as String? ?? '')
            .toSet();
      }

      // 5. Produits vendus dans ce magasin + map des prix pour CE magasin
      final pricedResponse = await http.get(Uri.parse('$baseUrl/priced-products?store_id=$storeId'));
      final pricedData = jsonDecode(pricedResponse.body);
      final storeProdIds = (pricedData['pricedProducts'] as List)
          .map<int>((r) => r['product_id'] as int)
          .toSet();

      // Build map product_id -> price info for this store
      final Map<int, Map<String, dynamic>> storePriceMap = {};
      if (pricedData['pricedProducts'] != null) {
        for (var priced in pricedData['pricedProducts']) {
          final productId = priced['product_id'] as int;
          final amount = _parsePrice(priced['amount']);
          final currency = priced['currency'] ?? 'CAD';
          // If multiple entries for same product in this store, keep lowest price
          if (!storePriceMap.containsKey(productId) || amount < (storePriceMap[productId]!['amount'] as double)) {
            storePriceMap[productId] = {
              'amount': amount,
              'currency': currency,
              'store_id': priced['store_id'],
            };
          }
        }
      }

      if (storeProdIds.isEmpty) {
        recos = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      // 6. Récupération + tri
      final allProdsResponse = await http.get(Uri.parse('$baseUrl/products'));
      final allProdsData = jsonDecode(allProdsResponse.body);
      final allProds = allProdsData['reviews'] as List;

      final b1 = <Map<String, dynamic>>[];
      final b2 = <Map<String, dynamic>>[];
      final b3 = <Map<String, dynamic>>[];

      for (final p in allProds) {
        final pid = p['product_id'] as int;
        if (!storeProdIds.contains(pid)) continue;

        final bc = p['bar_code'] ?? '';
        final priceInfo = storePriceMap[pid];
        final map = {
          'id': pid,
          'title': p['name'],
          'image': p['image_url'],
          'subtitle': p['category'] ?? '',
          'isFav': favIds.contains(pid),
          // prices from this store
          'price': priceInfo?['amount'] as double? ?? 0.0,
          'currency': priceInfo?['currency'] as String? ?? 'CAD',
          'store_id': priceInfo?['store_id'],
        };

        if (favIds.contains(pid)) {
          b1.add(map);
        } else if (bc.isNotEmpty && favBarcodes.contains(bc)) {
          b2.add(map);
        } else {
          b3.add(map);
        }
      }

      recos = [...b1, ...b2, ...b3].take(6).toList();
      isLoading = false;
      notifyListeners();
    } catch (e, st) {
      error = e.toString();
      isLoading = false;
      log('StorePageVM.load error: $e\n$st');
      notifyListeners();
    }
  }

  /* ───────── ajout / retrait fav ───────── */
  /// Ajoute ou retire le store des favoris
  Future<void> toggleFavorite(int storeId) async {
    final actor = await CurrentActorService.getCurrentActor(auth: auth);
    final userId = actor.actorId;
    final userEmail = actor.email ?? '${actor.firstName} ${actor.lastName}';

    if (isStoreFavorite) {
      // ➖ RETIRER
      final res = await http.delete(
        Uri.parse('$baseUrl/favorite-stores/$userId/$storeId'),
      );
      if (res.statusCode == 200) {
        isStoreFavorite = false;
      } else {
        error = 'Erreur lors du retrait des favoris';
      }
    } else {
      // ➕ AJOUTER
      final res = await http.post(
        Uri.parse('$baseUrl/favorite-stores'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'actor_id': userId,
          'store_id': storeId,
          'created_by' : actor.email ?? '${actor.firstName} ${actor.lastName}',
        }),
      );
      if (res.statusCode == 201) {
        isStoreFavorite = true;
      } else {
        error = 'Erreur lors de l\'ajout aux favoris';
      }
    }
    notifyListeners();
  }

  /* ──────────── HELPERS ──────────── */
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
