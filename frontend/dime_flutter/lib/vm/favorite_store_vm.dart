import 'package:supabase_flutter/supabase_flutter.dart';
import 'current_actor_vm.dart';
import '../view/client/favorite_menu.dart';

/// Représente un commerce (id + nom)
class Store {
  final int id;
  final String name;
  Store(this.id, this.name);
}

/// Service MVVM pour charger les commerces favoris
class FavoriteStoreService {
  static Future<List<Store>> fetchFavorites(int actorId) async {
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from('favorite_store')
        .select('store_id, store(name)')
        .eq('actor_id', actorId) as List<dynamic>;

    return data.map((row) {
      return Store(
        row['store_id'] as int,
        (row['store'] as Map<String, dynamic>)['name'] as String,
      );
    }).toList();
  }
}