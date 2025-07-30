import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class CurrentStoreService {
  /* ───────────── constantes ───────────── */
  static const _prefsKey = 'current_store_id';
  static final SupabaseClient _client = Supabase.instance.client;

  /* ─────────── getters / setters ─────────── */

  /// ID du magasin actuellement sélectionné – peut être `null`
  static Future<int?> getCurrentStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefsKey);
  }

  /// Nom du magasin sélectionné – peut être `null`
  static Future<String?> getCurrentStoreName() async {
    final id = await getCurrentStoreId();
    if (id == null) return null;

    final row = await _client
        .from('store')
        .select('name')
        .eq('store_id', id)
        .maybeSingle();

    return row?['name'] as String?;
  }

  /// Change le magasin courant et le persiste dans SharedPreferences
  static Future<void> setCurrentStore(int storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, storeId);
    debugPrint('🏪 Current store set: $storeId');
  }

  /// Réinitialise (par ex. à la déconnexion)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  /* ─────────── utilitaires ─────────── */

  /// Retourne tous les magasins appartenant à `actorId` (owner)
  static Future<List<Map<String, dynamic>>> fetchStoresForOwner(
    int actorId,
  ) async {
    final rows = await _client
        .from('store')
        .select('store_id, name')
        .eq('actor_id', actorId);

    return List<Map<String, dynamic>>.from(rows);
  }
}
