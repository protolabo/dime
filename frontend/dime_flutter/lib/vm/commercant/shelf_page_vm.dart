import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:dime_flutter/vm/current_store.dart';

/// Représente un item (produit) présent sur l’étagère
class ShelfItem {
  final int productId;
  final String name;
  final double? price;
  final String? currency;

  ShelfItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.currency,
  });
}

/// VM de la page d’étagère (côté commerçant)
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

  final _supabase = Supabase.instance.client;

  Future<void> init() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      Map<String, dynamic>? shelfRow;

      // ── 1) Résoudre l’étagère
      if (initialShelfId != null) {
        shelfRow = await _supabase
            .from('shelf')
            .select('shelf_id,name,store_id,qr_code')
            .eq('shelf_id', initialShelfId!) // non-null
            .maybeSingle();
      } else if (initialQrData != null) {
        final data = initialQrData!;
        Map<String, dynamic>? byPayload;

        // a) Essaye d'interpréter le QR comme JSON {"type":"shelf","shelf_id":N}
        try {
          final parsed = jsonDecode(data);
          if (parsed is Map && parsed['shelf_id'] != null) {
            byPayload = await _supabase
                .from('shelf')
                .select('shelf_id,name,store_id,qr_code')
                .eq('shelf_id', (parsed['shelf_id'] as num).toInt())
                .maybeSingle();
          }
        } catch (_) {
          // pas du JSON → on tentera par qr_code
        }

        // b) Fallback : recherche par égalité sur la DataURL (rare)
        shelfRow = byPayload ??
            await _supabase
                .from('shelf')
                .select('shelf_id,name,store_id,qr_code')
                .eq('qr_code', data)
                .maybeSingle();
      } else {
        // c) Recherche par (store_id, name) si on vient d’un clic interne
        final currentStoreId = await CurrentStoreService.getCurrentStoreId();
        if (currentStoreId == null) {
          error = 'Store non sélectionné.';
          loading = false;
          notifyListeners();
          return;
        }
        shelfRow = await _supabase
            .from('shelf')
            .select('shelf_id,name,store_id,qr_code')
            .eq('store_id', currentStoreId)
            .eq('name', initialShelfName)
            .maybeSingle();
      }

      if (shelfRow == null) {
        error = 'Shelf introuvable.';
        loading = false;
        notifyListeners();
        return;
      }

      shelfId = shelfRow['shelf_id'] as int;
      shelfName = (shelfRow['name'] as String?) ?? initialShelfName;
      storeId = shelfRow['store_id'] as int?;
      qrData = (shelfRow['qr_code'] as String?) ?? initialQrData;

      if (storeId == null) {
        error = 'Shelf sans store associé.';
        loading = false;
        notifyListeners();
        return;
      }

      // ── 2) Récupérer les produits de l’étagère
      final sp = await _supabase
          .from('shelf_place')
          .select('product_id')
          .eq('shelf_id', shelfId!);

      final productIds = <int>[
        for (final r in (sp as List)) (r['product_id'] as int),
      ];

      if (productIds.isEmpty) {
        items = [];
        loading = false;
        notifyListeners();
        return;
      }

      // ── 3) Noms des produits
      final prows = await _supabase
          .from('product')
          .select('product_id,name')
          .inFilter('product_id', productIds);

      final nameById = <int, String>{
        for (final r in (prows as List))
          (r['product_id'] as int): (r['name'] as String?) ?? 'Unnamed',
      };

      // ── 4) Prix des produits pour ce store
      final priceRows = await _supabase
          .from('priced_product')
          .select('product_id,amount,currency')
          .eq('store_id', storeId!) // non-null
          .inFilter('product_id', productIds);

      final priceById = <int, Map<String, dynamic>>{
        for (final r in (priceRows as List)) (r['product_id'] as int): r,
      };

      // ── 5) Build items
      items = productIds
          .map((pid) {
        final name = nameById[pid] ?? 'Product $pid';
        final priceMap = priceById[pid];
        final amount = (priceMap?['amount'] as num?)?.toDouble();
        final currency = priceMap?['currency'] as String?;
        return ShelfItem(
          productId: pid,
          name: name,
          price: amount,
          currency: currency,
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

  /// Génère un PDF en réutilisant **exactement** l’image DataURL stockée en BD.
  /// Si absente, fallback sur un QR régénéré à partir d’un payload déterministe.
  Future<void> downloadQrPdf() async {
    final doc = pw.Document();
    final title = shelfName ?? initialShelfName;

    pw.Widget qrWidget;
    final dataUrl = qrData;

    if (dataUrl != null && dataUrl.startsWith('data:image')) {
      final bytes = _dataUrlToBytes(dataUrl);
      final img = pw.MemoryImage(bytes);
      qrWidget = pw.Image(img, width: 240, height: 240);
    } else {
      // Fallback (rare) : QR à partir d’un payload stable
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
  }

  /// Refresh l'étagère après l'ajout d'éléments.
  Future<void> reload() async {
    try {
      // Si on n’a pas l’info minimale, retombe sur init()
      if (shelfId == null || storeId == null) {
        await init();
        return;
      }

      error = null;

      final sp = await _supabase
          .from('shelf_place')
          .select('product_id')
          .eq('shelf_id', shelfId!);

      final productIds = <int>[
        for (final r in (sp as List)) r['product_id'] as int,
      ];

      final prows = await _supabase
          .from('product')
          .select('product_id,name')
          .inFilter('product_id', productIds);

      final nameById = <int, String>{
        for (final r in (prows as List))
          (r['product_id'] as int): (r['name'] as String?) ?? 'Unnamed',
      };

      final priceRows = await _supabase
          .from('priced_product')
          .select('product_id,amount,currency')
          .eq('store_id', storeId!)
          .inFilter('product_id', productIds);

      final priceById = <int, Map<String, dynamic>>{
        for (final r in (priceRows as List)) (r['product_id'] as int): r,
      };

      items = productIds
          .map((pid) => ShelfItem(
        productId: pid,
        name: nameById[pid] ?? 'Product $pid',
        price: (priceById[pid]?['amount'] as num?)?.toDouble(),
        currency: priceById[pid]?['currency'] as String?,
      ))
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }


  // Helpers
  Uint8List _dataUrlToBytes(String dataUrl) {
    final idx = dataUrl.indexOf(',');
    final b64 = idx >= 0 ? dataUrl.substring(idx + 1) : dataUrl;
    return base64Decode(b64);
  }
}
