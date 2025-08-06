import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// ViewModel utilisé par `CreateItemPage`.
/// – Enregistre l’article dans le backend Express (/item/new)
/// – Récupère l’image QR au format data-URL
class CreateItemViewModel extends ChangeNotifier {
  /* ─────────────── Public state ─────────────── */
  String? qrDataUrl;       //  <img src="data:image/png;base64,…">
  String? errorMessage;

  bool  _isSaving = false;
  bool  get isSaving => _isSaving; // ← utilisé par la page pour afficher le loader

  /* ─────────────── Main action ─────────────── */
  Future<void> saveItem({
    required String name,
    required String barCode,
    required String price,
    required String description,
    required BuildContext context,
  }) async {
    if (_isSaving) return;           // évite les double-taps
    _isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      /* 🔥 POST vers ton serveur Express */
      final uri = Uri.parse('http://10.0.0.168:3000/item/new'); // adapte l’IP
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'name'       : name,
          'barcode'    : barCode,
          'price'      : price,
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        // On extrait l’URL base64 venant du HTML retourné
        final match = RegExp(r'<img src="(data:image/png;base64,[^"]+)"')
            .firstMatch(response.body);

        qrDataUrl = match?.group(1);
        if (qrDataUrl == null) {
          errorMessage = 'QR introuvable dans la réponse';
        } else {
          // Optionnel : feedback visuel
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produit enregistré ✔')),
            );
          }
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
