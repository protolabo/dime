import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorePageVM extends ChangeNotifier {
  final SupabaseClient _c = Supabase.instance.client;

  List<Map<String, dynamic>> recos = [];

  Future<void> load(int storeId, {int userId = 1}) async {
    /* -------- favoris de l'utilisateur (actor_id) -------- */
    final favRows = await _c
        .from('favorite_product')
        .select('product_id')
        .eq('actor_id', userId);

    final favIds = favRows.map<int>((e) => e['product_id'] as int).toSet();

    /* -------- barcodes des favoris -------- */
    Set<String> favBarcodes = {};
    if (favIds.isNotEmpty) {
      final allFavs = await _c
          .from('product')
          .select('product_id,bar_code');

      favBarcodes = allFavs
          .where((r) => favIds.contains(r['product_id']))
          .map<String>((r) => r['bar_code'] as String? ?? '')
          .toSet();
    }

    /* -------- produits vendus dans le magasin -------- */
    final priced = await _c
        .from('priced_product')
        .select('product_id')
        .eq('store_id', storeId);

    final storeProdIds =
    priced.map<int>((r) => r['product_id'] as int).toSet();

    if (storeProdIds.isEmpty) {
      recos = [];
      notifyListeners();
      return;
    }

    /* -------- infos complètes des produits -------- */
    final allProds = await _c
        .from('product')
        .select('product_id,name,category,bar_code');

    /* -------- buckets selon tes règles -------- */
    final b1 = <Map<String, dynamic>>[]; // déjà favoris
    final b2 = <Map<String, dynamic>>[]; // même barcode
    final b3 = <Map<String, dynamic>>[]; // autres

    for (final p in allProds) {
      final int pid = p['product_id'];
      if (!storeProdIds.contains(pid)) continue;

      final String bc = p['bar_code'] ?? '';
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
    log('Store $storeId → recos=${recos.length}');
    notifyListeners();
  }
}
