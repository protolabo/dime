import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/vm/current_connected_account_vm.dart';

import '../../auth_viewmodel.dart';

class CreateShelfViewModel extends ChangeNotifier {
  final AuthViewModel auth;
  String? qrDataUrl;
  String? errorMessage;

  CreateShelfViewModel({required this.auth});

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Future<void> saveShelf({
    required String shelfName,
    required BuildContext context,
  }) async {
    if (shelfName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a shelf name.')),
      );
      return;
    }

    _isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Store courant
      final storeId = await CurrentStoreService.getCurrentStoreId();
      if (storeId == null) {
        errorMessage = 'No store selected.';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a store first.')),
        );
        _isSaving = false;
        notifyListeners();
        return;
      }

      // Commerçant courant (pour created_by)
      final merchant = await CurrentActorService.getCurrentMerchant(auth: auth);
      final createdBy = merchant.email; // on envoie l'email

      // Appel backend Express (même hôte que create_item_vm)
      final uri = Uri.parse('http://localhost:3001/shelves');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shelfName': shelfName,
          'store_id': storeId.toString(),
          'location': '',
          'created_by': createdBy,
        }),

      );
      // print('Status: ${response.statusCode}');
      // print('Body: ${response.body}');
      if (response.statusCode == 201) {
        final html = response.body;
        final match = RegExp(r'src="(data:image[^"]+)"').firstMatch(html);
        if (match != null) {
          qrDataUrl = match.group(1);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Shelf created ✔')),
            );
          }
        } else {
          errorMessage = 'QR not found in server response.';
        }
      } else {
        errorMessage = 'Server error (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
