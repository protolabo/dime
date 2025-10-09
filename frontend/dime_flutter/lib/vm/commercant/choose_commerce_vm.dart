import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../current_connected_account_vm.dart';
import '../current_store.dart';
import '../../view/commercant/create_qr_menu.dart';

/// VM pour la page de choix de commerce (commerçant)
class ChooseCommerceViewModel extends ChangeNotifier {
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
      final uri = Uri.parse('http://localhost:3001/stores?actor_id=$actorId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        stores = List<Map<String, dynamic>>.from(data['favorites']);
      } else {
        error = 'Erreur serveur (${response.statusCode}) : ${response.body}';
      }
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
        MaterialPageRoute(builder: (_) => const CreateQrMenuPage()),
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
