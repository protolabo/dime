import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/vm/current_connected_account_vm.dart';

/// ViewModel utilisé par `CreateItemPage`.
/// – Enregistre l’article dans le backend Express (/item/new)
/// – Récupère l’image QR au format data-URL renvoyée par l’EJS du backend
class CreateItemViewModel extends ChangeNotifier {
  /* ─────────────── Public state ─────────────── */
  String? qrDataUrl;       //  <img src="data:image/png;base64,…">
  String? errorMessage;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /* ─────────────── Main action ─────────────── */
  Future<void> saveItem({
    required BuildContext context,
    required String name,
    required String barCode,
    String? description,
    String? price, // string pour laisser le champ vide si besoin
  }) async {
    if (_isSaving) return;
    _isSaving = true;
    errorMessage = null;
    qrDataUrl = null;
    notifyListeners();

    try {
      // 1) Récupérer le commerçant connecté et le store sélectionné
      final merchant = await CurrentActorService.getCurrentMerchant();
      final storeId = await CurrentStoreService.getCurrentStoreId();

      if (storeId == null) {
        errorMessage = 'Aucun commerce sélectionné. Sélectionne un commerce d’abord.';
        return;
      }

      // 2) Appel backend (Express)
      // NOTE: laisse l’URL telle qu’utilisée avant; ajuste si besoin.
      final uri = Uri.parse('http://10.0.0.168:3000/item/new');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'name'       : name,
          'barcode'    : barCode,
          'price'      : price ?? '',
          'description': description ?? '',
          'store_id'   : storeId.toString(),
          'created_by' : merchant.email, // ou '${merchant.firstName} ${merchant.lastName} (#${merchant.actorId})'
        },
      );

      if (response.statusCode == 200) {
        // La page EJS renvoie un <img src="data:image/png;base64,...">
        final html = response.body;
        final match = RegExp(r'src="(data:image[^"]+)"').firstMatch(html);
        if (match != null) {
          qrDataUrl = match.group(1);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produit enregistré ✔')),
            );
          }
        } else {
          errorMessage = 'QR introuvable dans la réponse serveur.';
        }
      } else {
        errorMessage = 'Erreur serveur (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'Erreur : $e';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
