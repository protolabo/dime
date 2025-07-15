import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class CurrentStoreService {
  static final SupabaseClient _client = Supabase.instance.client;

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
}
