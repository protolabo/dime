import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/vm/current_connected_account_vm.dart';
import 'package:dime_flutter/vm/components/open_food_facts_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth_viewmodel.dart';

/// ViewModel utilisé par `CreateItemPage`.
/// – Enregistre l’article dans le backend Express (/item/new)
/// – Récupère l’image QR au format data-URL renvoyée par l’EJS du backend
class CreateItemViewModel extends ChangeNotifier {
  /* ─────────────── Public state ─────────────── */
  String? qrDataUrl;
  String? errorMessage;
  final AuthViewModel auth;
  CreateItemViewModel({required this.auth});
  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /* ─────────────── Main action ─────────────── */
  Future<OffProduct?> lookupBarcode(String barcode) async {
    try {
      return await OpenFoodFactsService.fetchProduct(barcode);
    } catch (_) {
      return null;
    }
  }
  void setImage(XFile? image) {
    _selectedImage = image;
    notifyListeners();
  }

  Future<void> saveItem({
    required BuildContext context,
    required String name,
    required String barCode,
    String? description,
    String? price,
  }) async {
    if (_isSaving) return;
    _isSaving = true;
    errorMessage = null;
    qrDataUrl = null;
    notifyListeners();

    try {
      final storeId = await CurrentStoreService.getCurrentStoreId();
      final merchant = await CurrentActorService.getCurrentMerchant(auth: auth);

      if (storeId == null) {
        errorMessage = 'Aucun commerce sélectionné.';
        return;
      }

      final uri = Uri.parse('http://localhost:3001/products');
      final request = http.MultipartRequest('POST', uri);

      request.fields['name'] = name;
      request.fields['barcode'] = barCode;
      request.fields['price'] = price ?? '';
      request.fields['description'] = description ?? '';
      request.fields['store_id'] = storeId.toString();
      request.fields['created_by'] = merchant.email ?? '${merchant.firstName} ${merchant.lastName}';
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: _selectedImage!.name,
          ),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        final json = Map<String, dynamic>.from(jsonDecode(response.body));
        final product = json['product'] as Map<String, dynamic>?;
        qrDataUrl = product?['qr_code'] as String?;
        _selectedImage = null;

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produit enregistré ✔')),
          );
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

