import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dime_flutter/vm/current_connected_account_vm.dart';

class StorePageVM extends ChangeNotifier {
  final SupabaseClient _c = Supabase.instance.client;

  /* ───────── infos magasin ───────── */
  String? storeName;
  String? address;
  bool   isStoreFavorite = false;

  /* ───────── état UI ───────── */
  bool   isLoading = true;
  String? error;

  /* ───────── recommandations ───────── */
  List<Map<String, dynamic>> recos = [];

  /// Charge toutes les données nécessaires à l’écran.
  Future<void> load(int storeId) async {
    try {
      /* ---------- acteur courant ---------- */
      final actor = await CurrentActorService.getCurrentActor();
      final int userId = actor.actorId;

      /* ---------- détails du magasin ---------- */
      final s = await _c
          .from('store')
          .select('name,address,city,postal_code')
          .eq('store_id', storeId)
          .maybeSingle();

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

      /* ---------- est‐ce un favori ? ---------- */
      final favStore = await _c
          .from('favorite_store')
          .select('store_id')
          .eq('actor_id', userId)
          .eq('store_id', storeId)
          .maybeSingle();
      isStoreFavorite = favStore != null;

      /* ---------- produits favoris ---------- */
      final favRows = await _c
          .from('favorite_product')
          .select('product_id')
          .eq('actor_id', userId);
      final favIds = favRows.map<int>((e) => e['product_id'] as int).toSet();

      /* ---------- barcodes des favoris ---------- */
      Set<String> favBarcodes = {};
      if (favIds.isNotEmpty) {
        final allFavs =
        await _c.from('product').select('product_id,bar_code');
        favBarcodes = allFavs
            .where((r) => favIds.contains(r['product_id']))
            .map<String>((r) => r['bar_code'] as String? ?? '')
            .toSet();
      }

      /* ---------- produits vendus dans ce magasin ---------- */
      final priced = await _c
          .from('priced_product')
          .select('product_id')
          .eq('store_id', storeId);
      final storeProdIds =
      priced.map<int>((r) => r['product_id'] as int).toSet();

      if (storeProdIds.isEmpty) {
        recos = [];
        isLoading = false;
        notifyListeners();
        return;
      }

      /* ---------- récupération + tri ---------- */
      final allProds =
      await _c.from('product').select('product_id,name,category,bar_code');

      final b1 = <Map<String, dynamic>>[];
      final b2 = <Map<String, dynamic>>[];
      final b3 = <Map<String, dynamic>>[];

      for (final p in allProds) {
        final pid = p['product_id'] as int;
        if (!storeProdIds.contains(pid)) continue;

        final bc = p['bar_code'] ?? '';
        final map = {
          'id': pid,
          'title': p['name'],
          'subtitle': p['category'] ?? '',
          'isFav': favIds.contains(pid),
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
    final actor = await CurrentActorService.getCurrentActor();
    final userId = actor.actorId;
    final userEmail = actor.email;

    if (isStoreFavorite) {
      // ➖ RETIRER
      await Supabase.instance.client
          .from('favorite_store')
          .delete()
          .eq('actor_id', userId)
          .eq('store_id', storeId);
      isStoreFavorite = false;
    } else {
      // ➕ AJOUTER  (👉 on ajoute created_by)
      await Supabase.instance.client.from('favorite_store').insert({
        'actor_id'   : userId,
        'store_id'   : storeId,
        'created_by' : actor.email ?? '${actor.firstName} ${actor.lastName}',
      });
      isStoreFavorite = true;
    }

    notifyListeners();
  }

}
