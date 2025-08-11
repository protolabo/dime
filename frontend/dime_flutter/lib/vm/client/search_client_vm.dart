import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../current_connected_account_vm.dart';

class SearchViewModel extends ChangeNotifier {
  final SupabaseClient _c = Supabase.instance.client;

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

    final favProds = await _c
        .from('favorite_product')
        .select('product_id')
        .eq('actor_id', userId);        //  ← ICI : actor_id

    final favStores = await _c
        .from('favorite_store')
        .select('store_id')
        .eq('actor_id', userId);        //  ← ICI : actor_id

    final favProdIds  = favProds .map<int>((e) => e['product_id'] as int).toSet();
    final favStoreIds = favStores.map<int>((e) => e['store_id']  as int).toSet();
    log('   ✅ favProdIds=$favProdIds | favStoreIds=$favStoreIds');

    /* on récupère du contenu brut (12) */
    final rawProds = await _c
        .from('product')
        .select('product_id,name,category,created_at')
        .order('created_at', ascending: false)
        .limit(12);

    final rawStores = await _c
        .from('store')
        .select('store_id,name,city,created_at')
        .order('created_at', ascending: false)
        .limit(12);

    log('   🔢 rawProds=${rawProds.length} | rawStores=${rawStores.length}');

    /* étape 1 : sans favoris */
    final prodsNoFav  = rawProds
        .where((p) => !favProdIds.contains(p['product_id']))
        .take(3)
        .toList();

    final storesNoFav = rawStores
        .where((s) => !favStoreIds.contains(s['store_id']))
        .take(3)
        .toList();

    /* on complète si besoin */
    final extraProds  = prodsNoFav.length  < 3
        ? rawProds .where((p) => favProdIds .contains(p['product_id']))
        .take(3 - prodsNoFav.length).toList()
        : <Map>[];

    final extraStores = storesNoFav.length < 3
        ? rawStores.where((s) => favStoreIds.contains(s['store_id']))
        .take(3 - storesNoFav.length).toList()
        : <Map>[];

    recos = [
      ...prodsNoFav .map((p) => _mapProd (p, false)),
      ...extraProds .map((p) => _mapProd (p, true)),
      ...storesNoFav.map((s) => _mapStore(s, false)),
      ...extraStores.map((s) => _mapStore(s, true)),
    ];

    /* plan C – encore vide ? on balance ce qu’on a */
    if (recos.isEmpty) {
      log('   ⚠️  recos still empty → fallback to first 6 raw rows');
      recos = [
        ...rawProds .take(3).map((p) => _mapProd (p, favProdIds .contains(p['product_id']))),
        ...rawStores.take(3).map((s) => _mapStore(s, favStoreIds.contains(s['store_id']))),
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

    final prodF = _c.from('product')
        .select('product_id,name,category,bar_code')
        .or('name.ilike.%$q%,category.ilike.%$q%,bar_code.ilike.%$q%')
        .limit(10);

    final storeF = _c.from('store')
        .select('store_id,name,address,city,postal_code,country')
        .or('name.ilike.%$q%,address.ilike.%$q%,city.ilike.%$q%,postal_code.ilike.%$q%,country.ilike.%$q%')
        .limit(10);

    final [products, stores] = await Future.wait([prodF, storeF]);

    results = [
      ...products.map((p) => {
        'type':'product','id':p['product_id'],'title':p['name'],
        'subtitle':p['category'] ?? p['bar_code'] ?? ''
      }),
      ...stores.map((s) => {
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
    final userEmail = actor.email;          // varchar NOT NULL

    if (nowFav) {
      await _c.from('favorite_product').insert({
        'actor_id'   : userId,
        'product_id' : productId,
        'created_by' : userEmail,
      });
    } else {
      await _c.from('favorite_product')
          .delete()
          .eq('actor_id', userId)
          .eq('product_id', productId);
    }

    // on met à jour la liste locale (recos + results) pour refléter l’état
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
      await _c.from('favorite_store').insert({
        'actor_id'   : userId,
        'store_id'   : storeId,
        'created_by' : userEmail,
      });
    } else {
      await _c.from('favorite_store')
          .delete()
          .eq('actor_id', userId)
          .eq('store_id', storeId);
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
