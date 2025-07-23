import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'current_connected_client_vm.dart';

class ItemPageViewModel extends ChangeNotifier {
  final int productId;

  ItemPageViewModel({required this.productId}) {
    _fetchAll();
  }

  // -------------------- UI state --------------------
  bool isLoading = true;
  String? error;

  Map<String, dynamic>? product;          // name, bar_code …
  List<Map<String, dynamic>> stores = []; // store_id, store_name, amount
  Set<int> favStoreIds = {};              // stores favoris
  bool isFavorite = false;                // produit favori ?

  // -------------------- Load data --------------------
  Future<void> _fetchAll() async {
    final supabase = Supabase.instance.client;
    try {
      final actor = await CurrentActorService.getCurrentActor();

      // ---------- produit ----------
      product = await supabase
          .from('product')
          .select()
          .eq('product_id', productId)
          .single();

      // ---------- favori produit ? ----------
      final favProd = await supabase
          .from('favorite_product')
          .select('product_id')
          .eq('actor_id', actor.actorId)
          .eq('product_id', productId);
      isFavorite = favProd.isNotEmpty;

      // ---------- commerces + amount ----------
      final pricedRows = await supabase
          .from('priced_product')
          .select('store_id, amount, store:store_id(name)')
          .eq('product_id', productId);

      stores = pricedRows
          .map<Map<String, dynamic>>((row) => {
        'store_id': row['store_id'] as int,
        'store_name': (row['store'] as Map)['name'] as String,
        'amount': row['amount'],
      })
          .toList();

      // ---------- stores favoris ----------
      final favStoreRows = await supabase
          .from('favorite_store')
          .select('store_id')
          .eq('actor_id', actor.actorId);
      favStoreIds = favStoreRows.map<int>((r) => r['store_id'] as int).toSet();

      // tri : favoris d’abord, puis prix (amount) croissant
      stores.sort((a, b) {
        final favA = favStoreIds.contains(a['store_id']);
        final favB = favStoreIds.contains(b['store_id']);
        if (favA != favB) return favB ? 1 : -1; // favA d’abord
        return (a['amount'] as num).compareTo(b['amount'] as num);
      });
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  // -------------------- toggle cœur produit --------------------
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
      });
      isFavorite = true;
    }
    notifyListeners();
  }

  // -------------------- getters utilisés par l’UI --------------------
  List<Map<String, dynamic>> get storesWithPrice => stores;
  Set<int> get favoriteStoreIds => favStoreIds;
}
