import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../current_connected_account_vm.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class SearchViewModel extends ChangeNotifier {
  final baseUrl = 'http://localhost:3001';
  List<Map<String, dynamic>> recos   = [];
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;

  SearchViewModel() {
    _loadRecommendations();
  }

  /*────────────────────  RECO  ────────────────────*/


  Future<void> _loadRecommendations() async {
    final actor = await CurrentActorService.getCurrentActor();
    final userId = actor.actorId;

    // 1. Récupérer les favoris
    final favProdsResp = await http.get(Uri.parse('$baseUrl/favorite-products?actor_id=$userId'));
    final favStoresResp = await http.get(Uri.parse('$baseUrl/favorite-stores?actor_id=$userId'));

    final favProdsData = jsonDecode(favProdsResp.body);
    final favStoresData = jsonDecode(favStoresResp.body);

    final favProdIds = (favProdsData['favorites'] as List)
        .map<int>((e) => e['product_id'] as int)
        .toSet();
    final favStoreIds = (favStoresData['favoriteStores'] as List)
        .map<int>((e) => e['store_id'] as int)
        .toSet();

    // 2. Récupérer les produits et magasins récents
    final rawProdsResp = await http.get(Uri.parse('$baseUrl/products'));
    final rawStoresResp = await http.get(Uri.parse('$baseUrl/stores'));

    final rawProdsData = jsonDecode(rawProdsResp.body);
    final rawStoresData = jsonDecode(rawStoresResp.body);

    final rawProds = (rawProdsData['reviews'] as List)
        .where((p) => p['created_at'] != null)
        .toList()
      ..sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));
    final rawStores = (rawStoresData['favorites'] as List)
        .where((s) => s['created_at'] != null)
        .toList()
      ..sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));

    // Limite à 12
    final limitedProds = rawProds.take(12).toList();
    final limitedStores = rawStores.take(12).toList();

    // 3. Logique de sélection
    final prodsNoFav = limitedProds.where((p) => !favProdIds.contains(p['product_id'])).take(3).toList();
    final storesNoFav = limitedStores.where((s) => !favStoreIds.contains(s['store_id'])).take(3).toList();

    final extraProds = prodsNoFav.length < 3
        ? limitedProds.where((p) => favProdIds.contains(p['product_id'])).take(3 - prodsNoFav.length).toList()
        : <Map>[];

    final extraStores = storesNoFav.length < 3
        ? limitedStores.where((s) => favStoreIds.contains(s['store_id'])).take(3 - storesNoFav.length).toList()
        : <Map>[];

    recos = [
      ...prodsNoFav.map((p) => _mapProd(p, false)),
      ...extraProds.map((p) => _mapProd(p, true)),
      ...storesNoFav.map((s) => _mapStore(s, false)),
      ...extraStores.map((s) => _mapStore(s, true)),
    ];

    if (recos.isEmpty) {
      log('   ⚠️  recos still empty → fallback to first 6 raw rows');
      recos = [
        ...limitedProds.take(3).map((p) => _mapProd(p, favProdIds.contains(p['product_id']))),
        ...limitedStores.take(3).map((s) => _mapStore(s, favStoreIds.contains(s['store_id']))),
      ];
    }
    log('   🎁 recos size = ${recos.length}');
    notifyListeners();
  }


  Map<String, dynamic> _mapProd(Map p, bool fav) => {
    'type'    : 'product',
    'id'      : p['product_id'],
    'title'   : p['name'],
    'subtitle': p['category'] ?? '',
    'isFav'   : fav,
  };
  Map<String, dynamic> _mapStore(Map s, bool fav) => {
    'type'    : 'store',
    'id'      : s['store_id'],
    'title'   : s['name'],
    'subtitle': s['city'] ?? '',
    'isFav'   : fav,
  };

  /*────────────────────  AUTOCOMPLETE (inchangé)  ────────────────────*/
  Future<void> query(String input) async {
    final q = input.trim();
    if (q.isEmpty) { results = []; notifyListeners(); return; }

    isLoading = true; notifyListeners();

    final prodResponse = await http.get(
      Uri.parse('$baseUrl/products?queryClient=${Uri.encodeComponent(q)}'),
    );
    final prodData = jsonDecode(prodResponse.body);
    final List prodF = (prodData['reviews'] as List).take(10).toList();

    final storeResponse = await http.get(
      Uri.parse('$baseUrl/stores?query=${Uri.encodeComponent(q)}'),
    );
    final storeData = jsonDecode(storeResponse.body);
    final List storeF = (storeData['favorites'] as List).take(10).toList();


    results = [
      ...prodF.map((p) => {
        'type':'product','id':p['product_id'],'title':p['name'],
        'subtitle':p['category'] ?? p['bar_code'] ?? ''
      }),
      ...storeF.map((s) => {
        'type':'store','id':s['store_id'],'title':s['name'],
        'subtitle':'${s['city']??''} ${(s['postal_code']??'')} ${(s['country']??'')}'
      }),
    ];

    isLoading = false; notifyListeners();
  }

  // en haut du fichier (où tu veux, p.ex. juste sous le constructeur)
  /*────────── toggle favoris ──────────*/
  Future<void> toggleFavoriteProduct(int productId, bool nowFav) async {
    final actor = await CurrentActorService.getCurrentActor();
    final userId    = actor.actorId;
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

    for (final lst in [recos, results]) {
      for (final item in lst) {
        if (item['type'] == 'product' && item['id'] == productId) {
          item['isFav'] = nowFav;
        }
      }
    }
    notifyListeners();
  }

  Future<void> toggleFavoriteStore(int storeId, bool nowFav) async {
    final actor = await CurrentActorService.getCurrentActor();
    final userId    = actor.actorId;
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

    for (final lst in [recos, results]) {
      for (final item in lst) {
        if (item['type'] == 'store' && item['id'] == storeId) {
          item['isFav'] = nowFav;
        }
      }
    }
    notifyListeners();
  }


}
