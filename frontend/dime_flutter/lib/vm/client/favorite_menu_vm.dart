import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../current_connected_account_vm.dart';
import '../favorite_product_vm.dart';
import '../favorite_store_vm.dart';

/// View-Model pour la page `FavoriteMenuPage`
class FavoriteMenuVM extends ChangeNotifier {
  /* ────────────── état interne ────────────── */
  Client? _client;
  bool _loading = true;
  String? _error;

  final List<Product> favoriteProducts = [];
  final List<Store> favoriteStores   = [];

  final Map<int, bool> favoriteProductStates = {};
  final Map<int, bool> favoriteStoreStates   = {};

  /* ───────────── getters publics ───────────── */
  bool   get loading => _loading;
  String? get error  => _error;

  /* ───────────── initialisation ───────────── */
  Future<void> init() async {
    try {
      final actor   = await CurrentActorService.getCurrentActor();
      final products = await FavoriteProductService.fetchFavorites(actor.actorId);
      final stores   = await FavoriteStoreService.fetchFavorites(actor.actorId);

      _client
      = actor;                           // client connecté
      favoriteProducts
        ..clear() ..addAll(products);      // produits favoris
      favoriteStores
        ..clear() ..addAll(stores);        // commerces favoris
      favoriteProductStates
        ..clear() ..addEntries(products.map((p) => MapEntry(p.id, true)));
      favoriteStoreStates
        ..clear() ..addEntries(stores.map((s)   => MapEntry(s.id, true)));

      _loading = false;
      notifyListeners();
    } catch (e) {
      _error   = e.toString();
      _loading = false;
      notifyListeners();
    }
  }

  /* ─────────── toggle favoris (UI) ─────────── */
  void toggleProduct(int id, bool fav) {
    favoriteProductStates[id] = fav;
    notifyListeners();
  }

  void toggleStore(int id, bool fav) {
    favoriteStoreStates[id] = fav;
    notifyListeners();
  }

  /* ───────────── persistance BD ───────────── */
  Future<void> persistDeletions() async {
    if (_client == null) return;
    final sb = Supabase.instance.client;

    // produits
    for (final e in favoriteProductStates.entries) {
      if (!e.value) {
        await sb.from('favorite_product')
            .delete()
            .eq('actor_id', _client!.actorId)
            .eq('product_id', e.key);
      }
    }

    // commerces
    for (final e in favoriteStoreStates.entries) {
      if (!e.value) {
        await sb.from('favorite_store')
            .delete()
            .eq('actor_id', _client!.actorId)
            .eq('store_id', e.key);
      }
    }
  }
}
