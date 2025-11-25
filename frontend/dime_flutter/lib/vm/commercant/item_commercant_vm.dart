import 'dart:async';
import 'dart:convert';

import 'package:dime_flutter/vm/current_connected_account_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:http/http.dart' as http;
import 'package:dime_flutter/vm/current_store.dart';

import '../../auth_viewmodel.dart';

class ItemShelfRef {
  final int shelfId;
  final String name;
  ItemShelfRef({required this.shelfId, required this.name});
}

class ItemCommercantVM extends ChangeNotifier {
  final AuthViewModel auth;
  ItemCommercantVM({required this.productId, required this.initialProductName,required this.auth});
  static const String apiBaseUrl = 'http://localhost:3001';

  final int productId;
  final String initialProductName;

  // State
  String? productName;
  String? description;
  String? currency;
  double? price;
  String? qrDataUrl;
  String? imageUrl;

  List<ItemShelfRef> shelves = [];

  String? errorMessage;
  bool _loading = false;
  bool get isLoading => _loading;
  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    try {
      // product
      final prodResponse = await http.get(Uri.parse('$apiBaseUrl/products?product_id=$productId'));
      if (prodResponse.statusCode == 200) {
        final data = jsonDecode(prodResponse.body);
        final product = (data['reviews'] as List).isNotEmpty ? data['reviews'][0] : null;
        if (product != null) {
          productName = (product['name'] as String?)?.trim();
          description = product['description'] as String?;
          qrDataUrl = product['qr_code'] as String?;
          imageUrl = product['image_url'] as String?;
        }
      }

      // store
      final storeId = await CurrentStoreService.getCurrentStoreId();
      if (storeId != null) {
        // Price
        final priceResponseonse = await http.get(Uri.parse('$apiBaseUrl/priced-products?store_id=$storeId&product_id=$productId'));
        if (priceResponseonse.statusCode == 200) {
          final data = jsonDecode(priceResponseonse.body);
          final priced = (data['pricedProducts'] as List).isNotEmpty ? data['pricedProducts'][0] : null;
          if (priced != null) {
            final amt = priced['amount'];
            price = (amt is num) ? amt.toDouble() : double.tryParse('$amt');
            currency = priced['currency'] as String?;
          }
        }

        // Shelves
        final shelfPlaceResponse = await http.get(Uri.parse('$apiBaseUrl/shelf-places?product_id=$productId'));
        if (shelfPlaceResponse.statusCode == 200) {
          final data = jsonDecode(shelfPlaceResponse.body);
          final shelfPlaces = data['shelfPlaces'] as List;
          final ids = <int>{};
          for (final r in shelfPlaces) {
            final v = r['shelf_id'];
            if (v is int) ids.add(v);
          }
          if (ids.isNotEmpty) {
            final shelfIds = ids.join('&shelf_id=');
            final shelfResponseonse = await http.get(Uri.parse('$apiBaseUrl/shelves?store_id=$storeId&shelf_id=$shelfIds'));
            if (shelfResponseonse.statusCode == 200) {
              final data = jsonDecode(shelfResponseonse.body);
              shelves = (data['reviews'] as List)
                  .map((e) => ItemShelfRef(
                shelfId: e['shelf_id'] as int,
                name: (e['name'] as String?)?.trim().isNotEmpty == true
                    ? (e['name'] as String).trim()
                    : 'Shelf #${e['shelf_id']}',
              ))
                  .toList();
            }
          } else {
            shelves = [];
          }
        }
      }
    } catch (e, st) {
      errorMessage = 'Failed to load item: $e';
      if (kDebugMode) print('item vm init error: $e\n$st');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setImage(XFile? image) {
    _selectedImage = image;
    notifyListeners();
  }

  Future<void> updateImage() async {
    if (_selectedImage == null) return;

    try {
      final uri = Uri.parse('$apiBaseUrl/products/$productId/image');
      final request = http.MultipartRequest('PUT', uri);

      final bytes = await _selectedImage!.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: _selectedImage!.name,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        imageUrl = json['image_url'];
        _selectedImage = null;
        errorMessage = null;
      } else {
        errorMessage = 'Erreur lors de la mise à jour de l\'image';
      }
    } catch (e) {
      errorMessage = 'Erreur : $e';
    }
    notifyListeners();
  }



  Future<void> updateName(String newName) async {
    final name = newName.trim();
    if (name.isEmpty) return;

    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/products/$productId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'last_updated_by': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        productName = name;
        errorMessage = null;
      } else {
        final data = jsonDecode(response.body);
        errorMessage = data['error'] ?? '';
      }
    } catch (e) {
      errorMessage = 'Impossible de mettre à jour le nom: $e';
    }
    notifyListeners();
  }

/// Modifie le prix d'un item en question.
  Future<void> updatePrice(double newAmount, {String currencyCode = 'CAD'}) async {
    final storeId = await CurrentStoreService.getCurrentStoreId();
    if (storeId == null) {
      errorMessage = 'Aucun magasin sélectionné.';
      notifyListeners();
      return;
    }

    try {
      final merchant = await CurrentActorService.getCurrentMerchant(auth: auth);
      final email = merchant.email;

      // Vérifier si l'enregistrement existe déjà via l'API
      final checkResponse = await http.get(Uri.parse(
        '$apiBaseUrl/priced-products?store_id=$storeId&product_id=$productId',
      ));

      if (checkResponse.statusCode == 200) {
        final data = jsonDecode(checkResponse.body);
        final exists = (data['pricedProducts'] as List).isNotEmpty;

        if (exists) {
          // UPDATE
          final updateResponse = await http.put(
            Uri.parse('$apiBaseUrl/priced-products'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'store_id': storeId,
              'product_id': productId,
              'amount': newAmount,
              'currency': currencyCode,
              'last_updated_by': email,
            }),
          );
          if (updateResponse.statusCode != 200) {
            final error = jsonDecode(updateResponse.body);
            errorMessage = error['error'] ?? 'Erreur lors de la mise à jour du prix';
            notifyListeners();
            return;
          }
        } else {
          // INSERT
          final insertResponse = await http.post(
            Uri.parse('$apiBaseUrl/priced-products'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'store_id': storeId,
              'product_id': productId,
              'amount': newAmount,
              'currency': currencyCode,
              'created_by': email,
              'last_updated_by': email,
            }),
          );
          if (insertResponse.statusCode != 201) {
            final error = jsonDecode(insertResponse.body);
            errorMessage = error['error'] ?? 'Erreur lors de la création du prix';
            notifyListeners();
            return;
          }
        }

        price = newAmount;
        currency = currencyCode;
        errorMessage = null;
      } else {
        errorMessage = 'Erreur lors de la vérification du prix';
      }
    } catch (e) {
      errorMessage = 'Impossible de mettre à jour le prix: $e';
    }
    notifyListeners();
  }

  Future<bool> removeFromCurrentStore() async {
    final storeId = await CurrentStoreService.getCurrentStoreId();
    if (storeId == null) {
      errorMessage = 'Aucun magasin sélectionné.';
      notifyListeners();
      return false;
    }

    try {
      // 1) Supprimer le prix du produit pour ce magasin
      final priceResponse = await http.delete(
        Uri.parse('$apiBaseUrl/priced-products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'store_id': storeId,
          'product_id': productId,
        }),
      );
      //print('price delete response: ${priceResponse.statusCode} - ${priceResponse.body}');
      if (priceResponse.statusCode != 200) {
        final error = jsonDecode(priceResponse.body);
        errorMessage = error['error'] ?? 'Erreur lors de la suppression du prix';
        notifyListeners();
        return false;
      }

      // 2) Récupérer les shelf_id du store
      final shelfResponse = await http.get(
        Uri.parse('$apiBaseUrl/shelves?store_id=$storeId'),
      );
      //print('shelf fetch response: ${shelfResponse.statusCode} - ${shelfResponse.body}');
      if (shelfResponse.statusCode != 200) {
        final error = jsonDecode(shelfResponse.body);
        errorMessage = error['error'] ?? 'Erreur lors de la récupération des étagères';
        notifyListeners();
        return false;
      }
      final shelfData = jsonDecode(shelfResponse.body);
      final shelfIds = (shelfData['reviews'] as List)
          .map<int>((e) => e['shelf_id'] as int)
          .toList();

      // 3) Supprimer les shelf_places pour ce produit sur ces étagères
      for (final shelfId in shelfIds) {
        final deleteResponse = await http.delete(
          Uri.parse('$apiBaseUrl/shelf-places'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'shelf_id': shelfId,
            'product_id': productId,
          }),
        );
        //print('shelf_place delete response for shelf $shelfId: ${deleteResponse.statusCode} - ${deleteResponse.body}');
        if (deleteResponse.statusCode != 200 && deleteResponse.statusCode != 404) {
          final error = jsonDecode(deleteResponse.body);
          errorMessage = error['error'] ?? 'Erreur lors de la suppression de shelf_place';
          notifyListeners();
          return false;
        }
      }

      shelves = [];
      return true;
    } catch (e) {
      errorMessage = 'Suppression impossible: $e';
      notifyListeners();
      return false;
    }
  }

  /// Exporte le QR Code de l’item en PDF (même logique que ShelfPageVM).
  Future<void> downloadItemQrPdf() async {
    final dataUrl = qrDataUrl;
    final name = (productName ?? initialProductName).trim();
    if (dataUrl == null || dataUrl.isEmpty) {
      errorMessage = 'QR Code indisponible pour cet item.';
      notifyListeners();
      return;
    }

    final img = await networkImage(dataUrl);
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 16),
              pw.Text(
                name.isEmpty ? 'Item #$productId' : name,
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Container(
                width: 220,
                height: 220,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.black, width: 1),
                ),
                child: pw.Center(child: pw.Image(img)),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'item_${productId}_${name.isEmpty ? "qr" : name}.pdf',
    );
  }

}
