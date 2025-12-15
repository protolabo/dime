import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:dime_flutter/vm/current_store.dart';

// Constante pour l'URL de base de l'API
  final String apiBaseUrl = dotenv.env['BACKEND_API_URL'] ?? '';
/// Représente un item (produit) présent sur l'étagère
class ShelfItem {
  final int productId;
  final String name;
  final double? price;
  final String? currency;
  final String? imageUrl;

  ShelfItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.currency,
    required this.imageUrl
  });
}

/// VM de la page d'étagère (côté commerçant)
class ShelfPageVM extends ChangeNotifier {
  ShelfPageVM({
    required this.initialShelfName,
    this.initialShelfId,
    this.initialQrData,
  });

  /// Paramètres de navigation
  final String initialShelfName;
  final int? initialShelfId;
  /// Peut être un payload JSON scanné (ex: {"type":"shelf","shelf_id":1})
  /// ou une DataURL (si tu la passes ainsi).
  final String? initialQrData;

  /// State
  bool loading = true;
  String? error;

  int? shelfId;
  String? shelfName;
  int? storeId;

  /// DataURL du QR stockée en BD (colonne `shelf.qr_code`)
  String? qrData;

  List<ShelfItem> items = [];

  XFile? _selectedImage;
  XFile? get selectedImage => _selectedImage;
  String? imageUrl;


  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      Map<String, dynamic>? shelfRow;

      // ── 1) Résoudre l'étagère
      if (initialShelfId != null) {
        final response = await http.get(
          Uri.parse('$apiBaseUrl/shelves?shelf_id=$initialShelfId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final shelves = data['reviews'] as List;
          shelfRow = shelves.isNotEmpty ? shelves.first : null;
        }
      } else if (initialQrData != null) {
        final data = initialQrData!;
        Map<String, dynamic>? byPayload;

        // a) Essaye d'interpréter le QR comme JSON {"type":"shelf","shelf_id":N}
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map && parsed['shelf_id'] != null) {
            final shelfIdFromQr = (parsed['shelf_id'] as num).toInt();
            final response = await http.get(
              Uri.parse('$apiBaseUrl/shelves?shelf_id=$shelfIdFromQr'),
            );

            if (response.statusCode == 200) {
              final data = jsonDecode(response.body);
              final shelves = data['reviews'] as List;
              byPayload = shelves.isNotEmpty ? shelves.first : null;
            }
          }
        } catch (_) {
          // pas du JSON → on tentera par qr_code
        }

        // b) Fallback : recherche par égalité sur la DataURL (rare)
        if (byPayload == null) {
          final response = await http.get(
            Uri.parse('$apiBaseUrl/shelves?qr_code=${Uri.encodeComponent(data)}'),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final shelves = data['reviews'] as List;
            shelfRow = shelves.isNotEmpty ? shelves.first : null;
          }
        } else {
          shelfRow = byPayload;
        }
      } else {
        // c) Recherche par (store_id, name) si on vient d'un clic interne
        final currentStoreId = await CurrentStoreService.getCurrentStoreId();
        if (currentStoreId == null) {
          error = 'Store Not selected.';
          loading = false;
          notifyListeners();
          return;
        }

        final response = await http.get(
          Uri.parse('$apiBaseUrl/shelves?store_id=$currentStoreId&name=${Uri.encodeComponent(initialShelfName)}'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final shelves = data['reviews'] as List;
          shelfRow = shelves.isNotEmpty ? shelves.first : null;
        }
      }

      if (shelfRow == null) {
        error = 'Shelf not found.';
        loading = false;
        notifyListeners();
        return;
      }

      shelfId = shelfRow['shelf_id'] as int;
      shelfName = (shelfRow['name'] as String?) ?? initialShelfName;
      storeId = shelfRow['store_id'] as int?;
      qrData = (shelfRow['qr_code'] as String?) ?? initialQrData;
      imageUrl = shelfRow['image_url'] as String?;
      if (storeId == null) {
        error = 'Shelf with no associated store.';
        loading = false;
        notifyListeners();
        return;
      }

      // ── 2) Récupérer les produits de l'étagère
      final response = await http.get(
        Uri.parse('$apiBaseUrl/shelf-places?shelf_id=$shelfId'),
      );

      List<int> productIds = [];
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final shelfPlaces = data['shelfPlaces'] as List;
        productIds = [
          for (final r in shelfPlaces) (r['product_id'] as int),
        ];
      }

      if (productIds.isEmpty) {
        items = [];
        loading = false;
        notifyListeners();
        return;
      }

      // ── 3) Noms des produits
      final nameById = <int, String>{};
      final imageById = <int, String?>{};
      for (final pid in productIds) {
        final productResponse = await http.get(
          Uri.parse('$apiBaseUrl/products?product_id=$pid'),
        );

        if (productResponse.statusCode == 200) {
          final data = jsonDecode(productResponse.body);
          final products = data['reviews'] as List;  // Contrôleur renvoie 'reviews'
          if (products.isNotEmpty) {
            nameById[pid] = (products.first['name'] as String?) ?? 'Unnamed';
            imageById[pid]= (products.first['image_url'] as String?) ;
          }
        }
      }

      // ── 4) Prix des produits pour ce store
      // Récupérer tous les prix pour ce magasin et filtrer côté client
      final priceResponse = await http.get(
        Uri.parse('$apiBaseUrl/priced-products?store_id=$storeId'),
      );

      final priceById = <int, Map<String, dynamic>>{};
      if (priceResponse.statusCode == 200) {
        final data = jsonDecode(priceResponse.body);
        final pricedProducts = data['pricedProducts'] as List;

        // Filtrer les prix pour ne garder que ceux des produits qui nous intéressent
        for (final r in pricedProducts) {
          final pid = r['product_id'] as int;
          if (productIds.contains(pid)) {
            priceById[pid] = r;
          }
        }
      }

      // ── 5) Build items
      items = productIds
          .map((pid) {
        final name = nameById[pid] ?? 'Product $pid';
        final image=imageById[pid];
        final priceMap = priceById[pid];
        final amount = (priceMap?['amount'] as num?)?.toDouble();
        final currency = priceMap?['currency'] as String?;
        return ShelfItem(
          productId: pid,
          name: name,
          price: amount,
          currency: currency,
          imageUrl: image
        );
      })
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      loading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      loading = false;
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
      final uri = Uri.parse('$apiBaseUrl/shelves/$shelfId/image');
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
        error = null;
      } else {
        error = 'Error while updating store image';
      }
    } catch (e) {
      error = 'Error : $e';
    }
    notifyListeners();
  }

  /// Génère un PDF en réutilisant **exactement** l'image DataURL stockée en BD.
  /// Si absente, fallback sur un QR régénéré à partir d'un payload déterministe.
  Future<void> downloadQrPdf() async {
    final doc = pw.Document();
    final title = shelfName ?? initialShelfName;

    pw.Widget qrWidget;
    final dataUrl = qrData;

    try {
      if (dataUrl != null) {
        final bytes = await _getQrBytes(dataUrl);
        final img = pw.MemoryImage(bytes);
        qrWidget = pw.Image(img, width: 240, height: 240);
      } else {
        final payload = 'shelf:${shelfId ?? title}';
        qrWidget = pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: payload,
          width: 240,
          height: 240,
        );
      }

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(title, style: const pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 20),
                qrWidget,
              ],
            ),
          ),
        ),
      );

      final bytes = await doc.save();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'shelf_${shelfId ?? title}_qr.pdf',
      );
    } catch (e) {
      error = 'Error generating QR PDF: $e';
      notifyListeners();
    }
  }

  /// Refresh l'étagère après l'ajout d'éléments.
  Future<void> reload() async {
    try {
      // Si on n'a pas l'info minimale, retombe sur init()
      if (shelfId == null || storeId == null) {
        await init();
        return;
      }

      error = null;

      // Récupérer les produits de l'étagère
      final spResponse = await http.get(
        Uri.parse('$apiBaseUrl/shelf-places?shelf_id=$shelfId'),
      );

      List<int> productIds = [];
      if (spResponse.statusCode == 200) {
        final data = jsonDecode(spResponse.body);
        final shelfPlaces = data['shelfPlaces'] as List;
        productIds = [
          for (final r in shelfPlaces) r['product_id'] as int,
        ];
      }

      // Récupérer les noms des produits
      final nameById = <int, String>{};
      final imageById = <int, String?>{};
      for (final pid in productIds) {
        final productResponse = await http.get(
          Uri.parse('$apiBaseUrl/products?product_id=$pid'),
        );

        if (productResponse.statusCode == 200) {
          final data = jsonDecode(productResponse.body);
          final products = data['reviews'] as List;
          if (products.isNotEmpty) {
            nameById[pid] = (products.first['name'] as String?) ?? 'Unnamed';
            imageById[pid]= (products.first['image_url'] as String?) ?? null;
          }
        }
      }

      // Récupérer les prix des produits
      final priceResponse = await http.get(
        Uri.parse('$apiBaseUrl/priced-products?store_id=$storeId'),
      );

      final priceById = <int, Map<String, dynamic>>{};
      if (priceResponse.statusCode == 200) {
        final data = jsonDecode(priceResponse.body);
        final pricedProducts = data['pricedProducts'] as List;

        // Filtrer côté client
        for (final r in pricedProducts) {
          final pid = r['product_id'] as int;
          if (productIds.contains(pid)) {
            priceById[pid] = r;
          }
        }
      }

      items = productIds
          .map((pid) => ShelfItem(
        productId: pid,
        name: nameById[pid] ?? 'Product $pid',
        price: (priceById[pid]?['amount'] as num?)?.toDouble(),
        currency: priceById[pid]?['currency'] as String?,
        imageUrl: imageById[pid] ?? null
      ))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
  /// Retire un produit de l'étagère
  Future<void> removeItemFromShelf(int productId) async {
    if (shelfId == null) {
      error = 'Shelf id messing';
      notifyListeners();
      return;
    }

    try {
      error = null;

      final response = await http.delete(
        Uri.parse('$apiBaseUrl/shelf-places'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shelf_id': shelfId,
          'product_id': productId,
        }),
      );

      if (response.statusCode == 200) {
        items.removeWhere((item) => item.productId == productId);
        notifyListeners();
      } else {
        final data = jsonDecode(response.body);
        error = data['error'] ?? 'Error While deleting the product';
        notifyListeners();
      }
    } catch (e) {
      error = 'Error : $e';
      notifyListeners();
    }
  }

  Future<void> deleteShelf() async {
    if (shelfId == null) {
      error = 'Shelf id missing';
      notifyListeners();
      return;
    }

    try {
      error = null;

      final response = await http.delete(
        Uri.parse('$apiBaseUrl/shelves/$shelfId'),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        error = data['error'] ?? 'Error while deleting the shelf';
        notifyListeners();
      }
    } catch (e) {
      error = 'Error : $e';
      notifyListeners();
    }
  }


  // Helpers

  /// Convertit une DataURL (data:*;base64,XXXXX) en bytes
  Uint8List _dataUrlToBytes(String dataUrl) {
    final idx = dataUrl.indexOf(',');
    final b64 = idx >= 0 ? dataUrl.substring(idx + 1) : dataUrl;
    return base64Decode(b64);
  }

  /// Récupère les bytes soit depuis une DataURL, soit depuis une URL HTTP(S)
  Future<Uint8List> _getQrBytes(String dataUrlOrUrl) async {
    if (dataUrlOrUrl.trim().isEmpty) {
      throw Exception('QR data empty');
    }

    // Data URL détectée
    if (dataUrlOrUrl.startsWith('data:')) {
      return _dataUrlToBytes(dataUrlOrUrl);
    }

    // URL HTTP(S) détectée -> fetch
    if (dataUrlOrUrl.startsWith('http://') || dataUrlOrUrl.startsWith('https://')) {
      final resp = await http.get(Uri.parse(dataUrlOrUrl));
      if (resp.statusCode == 200) {
        return resp.bodyBytes;
      }
      throw Exception('Failed to fetch QR image: ${resp.statusCode}');
    }

    // Fallback : tenter de décoder comme base64 pur
    try {
      return base64Decode(dataUrlOrUrl);
    } catch (_) {
      throw Exception('Unsupported QR data format');
    }
  }

}


