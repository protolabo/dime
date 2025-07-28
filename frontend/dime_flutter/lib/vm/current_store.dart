import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class CurrentStoreService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Retourne le nom du store du user connecté.
  static Future<String?> getCurrentStoreName() async {
    const int actorId = 1; // 🧪 test avec actor_id hardcodé

    final storeResponse = await _client
        .from('store')
        .select('name')
        .eq('actor_id', actorId)
        .maybeSingle();

    debugPrint("🏪 STORE FETCHED: $storeResponse");

    return storeResponse?['name'];
  }

  /// Retourne l'ID du store du user connecté.
  /// Pour l'instant, on utilise aussi actorId = 1 en dur.
  static Future<int> getCurrentStoreId() async {
    const int actorId = 1; // même hardcode que pour getCurrentStoreName

    final storeResponse = await _client
        .from('store')
        .select('store_id')
        .eq('actor_id', actorId)
        .maybeSingle();

    debugPrint("🏪 STORE ID FETCHED: $storeResponse");

    // si aucun résultat, on renvoie 1 par défaut
    return (storeResponse?['store_id'] as int?) ?? 1;
  }
}
