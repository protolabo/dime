import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dime_flutter/vm/current_connected_account_vm.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:dime_flutter/vm/current_store.dart';

class ItemShelfRef {
  final int shelfId;
  final String name;
  ItemShelfRef({required this.shelfId, required this.name});
}

class ItemCommercantVM extends ChangeNotifier {
  ItemCommercantVM({required this.productId, required this.initialProductName});

  final SupabaseClient _supabase = Supabase.instance.client;

  final int productId;
  final String initialProductName;

  // State
  String? productName;
  String? description;
  String? currency;
  double? price;
  String? qrDataUrl;

  List<ItemShelfRef> shelves = [];

  String? errorMessage;
  bool _loading = false;
  bool get isLoading => _loading;

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    try {
      // 1) product
      final prod = await _supabase
          .from('product')
          .select('name, description, qr_code')
          .eq('product_id', productId)
          .maybeSingle();

      if (prod != null) {
        productName = (prod['name'] as String?)?.trim();
        description = prod['description'] as String?;
        qrDataUrl = prod['qr_code'] as String?;
      }

      // 2) store-specific
      final storeId = await CurrentStoreService.getCurrentStoreId();
      if (storeId != null) {
        // price
        final priced = await _supabase
            .from('priced_product')
            .select('amount, currency')
            .eq('store_id', storeId)
            .eq('product_id', productId)
            .maybeSingle();

        if (priced != null) {
          final amt = priced['amount'];
          price = (amt is num) ? amt.toDouble() : double.tryParse('$amt');
          currency = priced['currency'] as String?;
        }

        // shelves
        final shelfPlaceRows = await _supabase
            .from('shelf_place')
            .select('shelf_id')
            .eq('product_id', productId);

        final ids = <int>{};
        for (final r in shelfPlaceRows as List) {
          final v = r['shelf_id'];
          if (v is int) ids.add(v);
        }

        if (ids.isNotEmpty) {
          final shelfRows = await _supabase
              .from('shelf')
              .select('shelf_id, name')
              .eq('store_id', storeId)
              .inFilter('shelf_id', ids.toList());

          shelves = (shelfRows as List)
              .map((e) => ItemShelfRef(
            shelfId: e['shelf_id'] as int,
            name: (e['name'] as String?)?.trim().isNotEmpty == true
                ? (e['name'] as String).trim()
                : 'Shelf #${e['shelf_id']}',
          ))
              .toList();
        } else {
          shelves = [];
        }
      }
    } catch (e, st) {
      errorMessage = 'Failed to load item: $e';
      if (kDebugMode) {
        // ignore: avoid_print
        print('item vm init error: $e\n$st');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateName(String newName) async {
    final name = newName.trim();
    if (name.isEmpty) return;

    try {
      await _supabase
          .from('product')
          .update({
        'name': name,
        'last_updated_at': DateTime.now().toIso8601String(),
      })
          .eq('product_id', productId);

      productName = name;
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
      final merchant = await CurrentActorService.getCurrentMerchant();
      final email = merchant.email;

      // Vérifier si l'enregistrement existe déjà
      final existing = await _supabase
          .from('priced_product')
          .select('store_id')
          .eq('store_id', storeId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        // UPDATE - l'enregistrement existe
        await _supabase
            .from('priced_product')
            .update({
          'amount': newAmount,
          'currency': currencyCode,
          'last_updated_by': email,
          // Ne pas inclure created_by lors d'un UPDATE
        })
            .eq('store_id', storeId)
            .eq('product_id', productId);
      } else {
        // INSERT - nouvel enregistrement
        await _supabase
            .from('priced_product')
            .insert({
          'store_id': storeId,
          'product_id': productId,
          'amount': newAmount,
          'currency': currencyCode,
          'created_by': email,
          'last_updated_by': email,
          // created_at et last_updated_at seront gérés automatiquement
        });
      }

      price = newAmount;
      currency = currencyCode;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Impossible de mettre à jour le prix: $e';
    }
    notifyListeners();
  }


  /// Supprime l’item de CE magasin : efface son prix et le retire des étagères du store.
  Future<bool> removeFromCurrentStore() async {
    final storeId = await CurrentStoreService.getCurrentStoreId();
    if (storeId == null) {
      errorMessage = 'Aucun magasin sélectionné.';
      notifyListeners();
      return false;
    }

    try {
      // 1) priced_product
      await _supabase
          .from('priced_product')
          .delete()
          .eq('store_id', storeId)
          .eq('product_id', productId);

      // 2) shelf_place pour les shelves de ce store
      final shelfRows = await _supabase
          .from('shelf')
          .select('shelf_id')
          .eq('store_id', storeId);

      final ids = (shelfRows as List).map<int>((e) => e['shelf_id'] as int).toList();
      if (ids.isNotEmpty) {
        await _supabase
            .from('shelf_place')
            .delete()
            .eq('product_id', productId)
            .inFilter('shelf_id', ids);
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

    final pngBytes = _dataUrlToBytes(dataUrl);
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
                child: pw.Center(child: pw.Image(pw.MemoryImage(pngBytes))),
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

  // Helpers
  Uint8List _dataUrlToBytes(String dataUrl) {
    final idx = dataUrl.indexOf(',');
    final b64 = idx >= 0 ? dataUrl.substring(idx + 1) : dataUrl;
    return base64Decode(b64);
  }
}
