import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

import 'current_store.dart';

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
  final MobileScannerController scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.qrCode,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
    ],
  );
  static const _baseUrl = 'http://localhost:3001';

  // multi overlays: key -> data
  final Map<String, Map<String, dynamic>> _overlays = {};
  Map<String, Map<String, dynamic>> get overlays => _overlays;

  // order stack (premier détecté = bas de la pile)
  final List<String> _stackKeys = [];
  List<String> get stackKeys => List.unmodifiable(_stackKeys);

  // geometry per key
  final Map<String, Rect> _qrRects = {};
  Rect? qrRectFor(String key) => _qrRects[key];

  // per-key busy and dedupe
  final Set<String> _busyKeys = {};
  final Map<String, DateTime> _lastSeen = {};

  // legacy single fields kept for compatibility (not used for multi)
  String? _currentKey;

  // visibilité
  static const Duration _visibilityTimeout = Duration(milliseconds: 1600);
  Timer? _visibilityTimer;

  ScanPageVM() {
    _startVisibilityTimer();
  }

  void _startVisibilityTimer() {
    _visibilityTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      final now = DateTime.now();
      final List<String> toRemove = [];
      _overlays.forEach((key, _) {
        final last = _lastSeen[key];
        if (last == null || now.difference(last) > _visibilityTimeout) {
          toRemove.add(key);
        }
      });
      if (toRemove.isNotEmpty) {
        for (final k in toRemove) {
          clearOverlay(k);
        }
      }
    });
  }

  Future<void> onDetect(
      BarcodeCapture capture,
      BuildContext context, {
        required Size previewSize,
        BoxFit boxFit = BoxFit.cover,
      }) async {
    if (capture.barcodes.isEmpty || capture.size == null) return;

    // première passe : mappe les rects pour l'affichage (utilise une clé normalisée previewKey)
    for (final b in capture.barcodes) {
      final rawRect = _rawRectFromBarcode(b);
      if (rawRect != null) {
        final rect = _mapImageRectToPreview(rawRect, capture.size!, previewSize, boxFit);
        final raw = b.rawValue ?? '';
        String previewKey = 'barcode:$raw';
        try {
          final parsed = jsonDecode(raw);
          if (parsed is Map) {
            final String? type = parsed['type'] as String?;
            final int? pid = type == 'product' ? parsed['product_id'] as int? : null;
            final int? sid = type == 'shelf' ? parsed['shelf_id'] as int? : null;
            if (pid != null) previewKey = 'product:$pid';
            else if (sid != null) previewKey = 'shelf:$sid';
          }
        } catch (_) {}
        _qrRects[previewKey] = rect;
      }
    }
    notifyListeners();

    // seconde passe : traite chaque code (normalise la clé en newKey)
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;

      String type = '';
      int? pid;
      int? sid;
      try {
        final data = jsonDecode(raw);
        if (data is Map) {
          type = (data['type'] as String?) ?? '';
          pid = type == 'product' ? data['product_id'] as int? : null;
          sid = type == 'shelf' ? data['shelf_id'] as int? : null;
        }
      } catch (_) {}

      final String newKey = (type == 'product' && pid != null)
          ? 'product:$pid'
          : (type == 'shelf' && sid != null)
          ? 'shelf:$sid'
          : 'barcode:$raw';

      final now = DateTime.now();
      final last = _lastSeen[newKey];
      if (last != null && now.difference(last) < const Duration(milliseconds: 1000)) {
        _lastSeen[newKey] = now; // rafraîchit timestamp même en cas de dédup
        continue;
      }
      _lastSeen[newKey] = now;

      if (_overlays.containsKey(newKey)) continue;
      if (_busyKeys.contains(newKey)) continue;

      if (_busyKeys.length >= 3) continue;

      _busyKeys.add(newKey);
      _processCode(newKey, raw, pid, sid);
    }
  }

  Future<void> _processCode(String key, String raw, int? pid, int? sid) async {
    try {
      if (pid != null) {
        await _handleProduct(pid, key);
      } else if (sid != null) {
        await _handleShelf(sid, key);
      } else {
        await _handleBarcode(raw, key);
      }
    } catch (_) {
      // ignore errors per key
    } finally {
      _busyKeys.remove(key);
      notifyListeners();
    }
  }

  Rect? _rawRectFromBarcode(Barcode b) {
    final corners = b.corners;
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

  Rect _mapImageRectToPreview(Rect raw, Size input, Size preview, BoxFit fit) {
    double scale;
    if (fit == BoxFit.cover) {
      scale = math.max(preview.width / input.width, preview.height / input.height);
    } else if (fit == BoxFit.contain) {
      scale = math.min(preview.width / input.width, preview.height / input.height);
    } else {
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

  Future<void> _handleProduct(int id, String key) async {
    final int? storeId = await CurrentStoreService.getCurrentStoreId();
    if (storeId == null) {
      _overlays[key] = {'kind': 'product', 'id': id, 'name': 'Item', 'error': 'no-store'};
      if (!_stackKeys.contains(key)) _stackKeys.add(key);
      notifyListeners();
      return;
    }

    try {
      dynamic product;
      final productResponse = await http.get(Uri.parse('$_baseUrl/products?product_id=$id'));
      if (productResponse.statusCode == 200) {
        final productData = jsonDecode(productResponse.body);
        final List<dynamic> products = productData['reviews'] ?? [];
        if (products.isEmpty) return;
        product = products.first;
      } else {
        return;
      }

      final priceResponse = await http.get(
        Uri.parse('$_baseUrl/priced-products?product_id=$id&store_id=$storeId'),
      );
      Map<String, dynamic>? priceRow;
      if (priceResponse.statusCode == 200) {
        final priceData = jsonDecode(priceResponse.body);
        final List<dynamic> prices = priceData['pricedProducts'] ?? [];
        if (prices.isNotEmpty) priceRow = prices.first;
      }

      _currentKey = key;
      _overlays[key] = {
        'kind': 'product',
        'id': id,
        'name': product['name'],
        'amount': priceRow?['amount'],
        'currency': priceRow?['currency'] ?? '\$',
        if (priceRow?['promotion_price'] != null) 'promo': priceRow!['promotion_price'],
        'promotion_id': priceRow?['promotion_id'],
      };
      if (!_stackKeys.contains(key)) _stackKeys.add(key);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _handleBarcode(String barcode, String key) async {
    final int? storeId = await CurrentStoreService.getCurrentStoreId();
    if (storeId == null) return;

    try {
      final resp = await http.get(Uri.parse('$_baseUrl/products?bar_code=$barcode'));
      if (resp.statusCode != 200) return;
      final data = jsonDecode(resp.body);
      final List<dynamic> products = data['reviews'] ?? [];
      if (products.isEmpty) return;
      final product = products.first;
      final int id = product['product_id'] as int;

      final priceResponse = await http.get(
        Uri.parse('$_baseUrl/priced-products?product_id=$id&store_id=$storeId'),
      );
      Map<String, dynamic>? priceRow;
      if (priceResponse.statusCode == 200) {
        final priceData = jsonDecode(priceResponse.body);
        final List<dynamic> prices = priceData['pricedProducts'] ?? [];
        if (prices.isNotEmpty) priceRow = prices.first;
      }

      _currentKey = 'product:$id';
      _overlays[key] = {
        'kind': 'product',
        'id': id,
        'name': product['name'],
        'amount': priceRow?['amount'],
        'currency': priceRow?['currency'] ?? '\$',
        if (priceRow?['promotion_price'] != null) 'promo': priceRow!['promotion_price'],
        'promotion_id': priceRow?['promotion_id'],
      };
      if (!_stackKeys.contains(key)) _stackKeys.add(key);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _handleShelf(int shelfId, String key) async {
    final int? storeId = await CurrentStoreService.getCurrentStoreId();
    if (storeId == null) return;

    try {
      final shelfResponse = await http.get(Uri.parse('$_baseUrl/shelves?shelf_id=$shelfId'));
      if (shelfResponse.statusCode != 200) return;
      final shelfData = jsonDecode(shelfResponse.body);
      final shelf = (shelfData['reviews'] as List?)?.firstWhere(
            (e) => e['shelf_id'] == shelfId,
        orElse: () => null,
      );
      if (shelf == null) return;
      final String shelfName = shelf['name'] as String? ?? 'Shelf #$shelfId';

      final spResponse = await http.get(Uri.parse('$_baseUrl/shelf-places?shelf_id=$shelfId'));
      if (spResponse.statusCode != 200) return;
      final spData = jsonDecode(spResponse.body);
      final List<dynamic> sp = spData['shelfPlaces'] ?? [];
      if (sp.isEmpty) {
        _overlays[key] = {'kind': 'shelf', 'shelfName': shelfName, 'items': <ShelfItemVM>[]};
        if (!_stackKeys.contains(key)) _stackKeys.add(key);
        notifyListeners();
        return;
      }
      final List<int> productIds = sp.map((e) => e['product_id'] as int).toList();

      final productsResponse = await http.get(Uri.parse(
        '$_baseUrl/products?${productIds.map((id) => 'product_id=$id').join('&')}',
      ));
      if (productsResponse.statusCode != 200) return;
      final productsData = jsonDecode(productsResponse.body);
      final List<dynamic> products = productsData['reviews'] ?? [];

      final pricedResponse = await http.get(Uri.parse(
        '$_baseUrl/priced-products?store_id=$storeId&${productIds.map((id) => 'product_id=$id').join('&')}',
      ));
      final List<dynamic> priceRows = (pricedResponse.statusCode == 200)
          ? (jsonDecode(pricedResponse.body)['pricedProducts'] ?? [])
          : [];

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
        final promosResponse = await http.get(Uri.parse(
          '$_baseUrl/promotions?${promoIds.map((id) => 'promotion_id=$id').join('&')}',
        ));
        if (promosResponse.statusCode == 200) {
          final promos = jsonDecode(promosResponse.body)['reviews'] ?? [];
          for (final p in promos) {
            promoById[p['promotion_id'] as int] = p;
          }
        }
      }

      final now = DateTime.now();

      final shelfItems = products.map((p) {
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

      _overlays[key] = {
        'kind': 'shelf',
        'shelfName': shelfName,
        'items': shelfItems,
      };
      if (!_stackKeys.contains(key)) _stackKeys.add(key);
      notifyListeners();
    } catch (_) {}
  }

  void clearOverlay([String? key]) {
    if (key == null) {
      _overlays.clear();
      _qrRects.clear();
      _busyKeys.clear();
      _currentKey = null;
      _stackKeys.clear();
      _lastSeen.clear();
    } else {
      _overlays.remove(key);
      _qrRects.remove(key);
      _busyKeys.remove(key);
      _stackKeys.remove(key);
      _lastSeen.remove(key);
      if (_currentKey == key) _currentKey = null;
    }
    scanner.start(); // relance la cam si besoin
    notifyListeners();
  }

  @override
  void dispose() {
    _visibilityTimer?.cancel();
    scanner.dispose();
    super.dispose();
  }
}
