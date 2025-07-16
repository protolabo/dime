import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateItemViewModel extends ChangeNotifier {
  String? qrDataUrl;
  bool isLoading = false;
  String? errorMessage;

  Future<void> generateQrCode({
    required String name,
    required String barcode,
    required String price,
    required String description,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final uri = Uri.parse('http://10.0.0.168:3000/item/new');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'name': name,
          'barcode': barcode,
          'price': price,
          'description': description,
        },
      );

      if (response.statusCode == 200) {
        final match = RegExp(
          r'<img src="(data:image/png;base64,[^"]+)"',
        ).firstMatch(response.body);
        qrDataUrl = match?.group(1);
        errorMessage = qrDataUrl == null ? "QR introuvable" : null;
      } else {
        errorMessage = "Erreur serveur (${response.statusCode})";
      }
    } catch (e) {
      errorMessage = "Erreur: $e";
    }

    isLoading = false;
    notifyListeners();
  }
}
