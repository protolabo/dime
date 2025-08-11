import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../current_store.dart';

enum ScanOverlayKind { none, product, shelf }

class ShelfItemVM {
  final int productId;
  final String name;
  final num? price;
  final String currency;
  final num? promoPrice;
  final bool promoActive;

  const ShelfItemVM({
    required this.productId,
    required this.name,
    required this.price,
    required this.currency,
    required this.promoPrice,
    required this.promoActive,
  });
}

class ScanPageVM extends ChangeNotifier {
  final MobileScannerController scanner = MobileScannerController();
  final SupabaseClient _sb = Supabase.instance.client;

  // Type d’overlay
  ScanOverlayKind _kind = ScanOverlayKind.none;
  ScanOverlayKind get kind => _kind;

  // Produit (overlay compact)
  Map<String, dynamic>? _productOverlay; // {id, name, amount, currency, promo?}
  Map<String, dynamic>? get overlayData => _productOverlay;

  // Étagère
  String? _shelfName;
  List<ShelfItemVM> _shelfItems = const [];
  String? get shelfName => _shelfName;
  List<ShelfItemVM> get shelfItems => _shelfItems;

  // UI
  bool _expanded = false; // étagère plein écran
  bool get expanded => _expanded;

  // Géométrie du QR en coordonnées écran
  Rect? _qrRect;
  Rect? get qrRect => _qrRect;

  // anti re-entrance / throttle / clé courante
  bool _busy = false;
  String? _lastRaw;
  DateTime _lastTime = DateTime.now();
  String? _currentKey; // "product:123" / "shelf:45"

  /* ─────────── SCAN CALLBACK ─────────── */
  Future<void> onDetect(
      BarcodeCapture capture,
      BuildContext context, {
        required Size previewSize,
        BoxFit boxFit = BoxFit.cover,
      }) async {
    // En plein écran d’étagère, on ignore (caméra est stoppée)
    if (_busy || (_kind == ScanOverlayKind.shelf && _expanded)) return;

    // Estimer la position du QR sur l’écran pour placer l’overlay
    if (capture.barcodes.isNotEmpty) {
      final b = capture.barcodes.first;
      final rawRect = _rawRectFromBarcode(b);
      if (rawRect != null && capture.size != null) {
        _qrRect = _mapImageRectToPreview(
          rawRect,
          capture.size,   // taille image de la frame
          previewSize,    // taille du widget MobileScanner
          boxFit,
        );
        if (_kind == ScanOverlayKind.none) notifyListeners();
      }
    }

    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw == null) continue;

      try {
        final data = jsonDecode(raw);
        if (data is! Map) continue;

        final String? type = data['type'] as String?;
        final int? pid = type == 'product' ? data['product_id'] as int? : null;
        final int? sid = type == 'shelf' ? data['shelf_id'] as int? : null;

        final String newKey = (type == 'product' && pid != null)
            ? 'product:$pid'
            : (type == 'shelf' && sid != null)
            ? 'shelf:$sid'
            : '';

        if (newKey.isEmpty) continue;
        if (_currentKey == newKey) return; // même QR -> ne rien faire

        // petit throttle
        final now = DateTime.now();
        if (raw == _lastRaw && now.difference(_lastTime) < const Duration(milliseconds: 500)) {
          return;
        }
        _lastRaw = raw;
        _lastTime = now;

        _busy = true;
        if (pid != null && type == 'product') {
          await _handleProduct(pid);
        } else if (sid != null && type == 'shelf') {
          await _handleShelf(sid);
        }
      } catch (_) {
        // ignore QR non reconnu
      } finally {
        _busy = false;
      }
      break; // on traite un seul code par frame
    }
  }

  /* ─────────── Helpers géométrie ─────────── */

  // Calcule un Rect en espace image à partir des coins (List<Offset>)
  Rect? _rawRectFromBarcode(Barcode b) {
    final corners = b.corners; // List<Offset>
    if (corners.isEmpty) return null;

    double minX = corners.first.dx, minY = corners.first.dy;
    double maxX = corners.first.dx, maxY = corners.first.dy;

    for (final o in corners) {
      if (o.dx < minX) minX = o.dx;
      if (o.dy < minY) minY = o.dy;
      if (o.dx > maxX) maxX = o.dx;
      if (o.dy > maxY) maxY = o.dy;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  // Mappe un rect "image" → "preview" selon le BoxFit utilisé
  Rect _mapImageRectToPreview(Rect raw, Size input, Size preview, BoxFit fit) {
    double scale;
    if (fit == BoxFit.cover) {
      scale = math.max(preview.width / input.width, preview.height / input.height);
    } else if (fit == BoxFit.contain) {
      scale = math.min(preview.width / input.width, preview.height / input.height);
    } else {
      // fallback raisonnable
      scale = math.min(preview.width / input.width, preview.height / input.height);
    }

    final scaledW = input.width * scale;
    final scaledH = input.height * scale;
    final dx = (preview.width - scaledW) / 2.0;
    final dy = (preview.height - scaledH) / 2.0;

    return Rect.fromLTRB(
      dx + raw.left * scale,
      dy + raw.top * scale,
      dx + raw.right * scale,
      dy + raw.bottom * scale,
    );
  }

  /* ─────────── PRODUIT ─────────── */
  Future<void> _handleProduct(int id) async {
    final int? storeId = await CurrentStoreService.getCurrentStoreId();
    if (storeId == null) return;

    try {
      final product = await _sb
          .from('product')
          .select('name')
          .eq('product_id', id)
          .maybeSingle();

      Map<String, dynamic>? priceRow;
      try {
        priceRow = await _sb
            .from('priced_product')
            .select('amount, currency, promotion_id, promotion_price')
            .eq('product_id', id)
            .eq('store_id', storeId)
            .maybeSingle();
      } catch (_) {
        priceRow = await _sb
            .from('priced_product')
            .select('amount, currency, promotion_id')
            .eq('product_id', id)
            .eq('store_id', storeId)
            .maybeSingle();
      }

      if (product != null) {
        _kind = ScanOverlayKind.product;
        _expanded = false;
        _shelfName = null;
        _shelfItems = const [];
        _currentKey = 'product:$id';

        _productOverlay = {
          'id': id,
          'name': product['name'],
          'amount': priceRow?['amount'],
          'currency': priceRow?['currency'] ?? '\$',
          if (priceRow?['promotion_price'] != null) 'promo': priceRow!['promotion_price'],
          'promotion_id': priceRow?['promotion_id'],
        };
        notifyListeners();
      }
    } catch (_) {}
  }

  /* ─────────── ÉTAGÈRE ─────────── */
  Future<void> _handleShelf(int shelfId) async {
    final int? storeId = await CurrentStoreService.getCurrentStoreId();
    if (storeId == null) return;

    try {
      final shelfRow = await _sb
          .from('shelf')
          .select('name, store_id')
          .eq('shelf_id', shelfId)
          .maybeSingle();
      if (shelfRow == null) return;

      _shelfName = shelfRow['name'] as String? ?? 'Shelf #$shelfId';

      final List<dynamic> sp = await _sb
          .from('shelf_place')
          .select('product_id')
          .eq('shelf_id', shelfId);

      if (sp.isEmpty) {
        _kind = ScanOverlayKind.shelf;
        _currentKey = 'shelf:$shelfId';
        _shelfItems = const [];
        _expanded = false;
        _productOverlay = null;
        notifyListeners();
        return;
      }

      final List<int> productIds = sp.map((e) => e['product_id'] as int).toList();

      final List<dynamic> products = await _sb
          .from('product')
          .select('product_id, name')
          .inFilter('product_id', productIds);

      List<dynamic> priceRows = [];
      try {
        priceRows = await _sb
            .from('priced_product')
            .select('product_id, amount, currency, promotion_id, promotion_price')
            .eq('store_id', storeId)
            .inFilter('product_id', productIds);
      } catch (_) {
        priceRows = await _sb
            .from('priced_product')
            .select('product_id, amount, currency, promotion_id')
            .eq('store_id', storeId)
            .inFilter('product_id', productIds);
      }

      final Map<int, Map<String, dynamic>> priceByPid = {
        for (final row in priceRows) row['product_id'] as int: row as Map<String, dynamic>
      };

      final promoIds = priceRows
          .map((e) => e['promotion_id'])
          .where((e) => e != null)
          .cast<int>()
          .toSet()
          .toList();

      Map<int, Map<String, dynamic>> promoById = {};
      if (promoIds.isNotEmpty) {
        try {
          final promos = await _sb
              .from('promotion')
              .select('promotion_id, start_date, end_date')
              .inFilter('promotion_id', promoIds);
          for (final p in promos) {
            promoById[p['promotion_id'] as int] = p as Map<String, dynamic>;
          }
        } catch (_) {}
      }

      final now = DateTime.now();

      _shelfItems = products.map((p) {
        final pid = p['product_id'] as int;
        final name = p['name'] as String? ?? 'Item $pid';
        final priceRow = priceByPid[pid];
        final num? amount = priceRow?['amount'] as num?;
        final String currency = (priceRow?['currency'] as String?) ?? '\$';

        bool promoActive = false;
        num? promoPrice;

        final promoId = priceRow?['promotion_id'] as int?;
        if (promoId != null) {
          final pr = promoById[promoId];
          if (pr != null) {
            try {
              final DateTime? start = pr['start_date'] != null ? DateTime.parse(pr['start_date']) : null;
              final DateTime? end = pr['end_date'] != null ? DateTime.parse(pr['end_date']) : null;
              if ((start == null || now.isAfter(start)) && (end == null || now.isBefore(end))) {
                promoActive = true;
              }
            } catch (_) {}
          }
          if (priceRow?['promotion_price'] != null) {
            final dynamic val = priceRow!['promotion_price'];
            if (val is num) promoPrice = val;
            if (val is String) promoPrice = num.tryParse(val);
          }
        }

        return ShelfItemVM(
          productId: pid,
          name: name,
          price: amount,
          currency: currency,
          promoPrice: promoPrice,
          promoActive: promoActive && promoPrice != null,
        );
      }).toList();

      _kind = ScanOverlayKind.shelf;
      _currentKey = 'shelf:$shelfId';
      _expanded = false;
      _productOverlay = null;
      notifyListeners();
    } catch (_) {}
  }

  /* ─────────── HELPERS ─────────── */
  void clearOverlay() {
    _kind = ScanOverlayKind.none;
    _productOverlay = null;
    _shelfName = null;
    _shelfItems = const [];
    _expanded = false;
    _currentKey = null;
    scanner.start(); // relance la cam si besoin
    notifyListeners();
  }

  void toggleExpanded() {
    _expanded = !_expanded;
    if (_kind == ScanOverlayKind.shelf) {
      if (_expanded) {
        scanner.stop();
      } else {
        scanner.start();
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    scanner.dispose();
    super.dispose();
  }
}
