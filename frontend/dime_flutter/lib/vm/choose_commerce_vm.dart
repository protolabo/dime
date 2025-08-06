import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'current_connected_account_vm.dart'; // ← service déjà fourni

class ChooseCommerceViewModel extends ChangeNotifier {
  ChooseCommerceViewModel() {
    _init();
  }

  bool isLoading = true;
  String? error;

  /// [{store_id, name}]
  List<Map<String, dynamic>> stores = [];

  Future<void> _init() async {
    try {
      final merchant = await CurrentActorService.getCurrentMerchant(); // actor_id = 2 test
      final data = await Supabase.instance.client
          .from('store')
          .select('store_id, name')
          .eq('actor_id', merchant.actorId);

      stores = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectStore(BuildContext context, Map<String, dynamic> store) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Commerce « ${store['name']} » sélectionné !')),
    );
  }
}
