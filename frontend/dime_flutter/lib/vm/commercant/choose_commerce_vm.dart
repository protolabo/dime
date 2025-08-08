import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../current_connected_account_vm.dart';
import '../current_store.dart';
import '../../view/commercant/create_item_page.dart';

/// VM pour la page de choix de commerce (commerçant)
class ChooseCommerceViewModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  bool   isLoading = true;
  String? error;
  List<Map<String, dynamic>> stores = []; // [{store_id, name}]

  ChooseCommerceViewModel() {
    _loadStores();
  }

  Future<void> _loadStores() async {
    final actor = await CurrentActorService.getCurrentMerchant();
    try {

      final int actorId = actor.actorId; // A CHANGER

      final resp = await _client
          .from('store')
          .select('store_id, name')
          .eq('actor_id', actorId);

      stores = List<Map<String, dynamic>>.from(resp);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectStore(BuildContext ctx, Map<String, dynamic> store) async {
    final int storeId    = store['store_id'] as int;
    // Si `setCurrentStore` attend le **nom**, passe plutôt `store['name']`
    try {
      await CurrentStoreService.setCurrentStore(storeId); // ajuste si besoin

      if (!ctx.mounted) return;
      Navigator.pushReplacement(
        ctx,
        MaterialPageRoute(builder: (_) => const CreateItemPage()),
      );
    } catch (e) {
      debugPrint('❌ selectStore error: $e');
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }
}
