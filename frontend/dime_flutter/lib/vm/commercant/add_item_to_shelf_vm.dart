import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../current_store.dart';
import '../current_connected_account_vm.dart';

enum AddItemMode { search, scan }

class ProductLite {
  final int id;
  final String? name;
  const ProductLite(this.id, this.name);
}

class SearchResult {
  final int productId;
  final String name;
  const SearchResult({required this.productId, required this.name});
}

class AddOutcome {
  final bool added;
  final String? reason;
  const AddOutcome.added() : added = true, reason = null;
  const AddOutcome.fail(this.reason) : added = false;
}

class AddItemToShelfVM extends ChangeNotifier {
  AddItemToShelfVM({required this.shelfId, required this.shelfName});

  final int shelfId;
  final String shelfName;

  final SupabaseClient _sb = Supabase.instance.client;

  // Mode
  AddItemMode _mode = AddItemMode.search;
  AddItemMode get mode => _mode;
  void setMode(AddItemMode m) {
    if (_mode == m) return;
    _mode = m;
    if (m == AddItemMode.scan) {
      clearOverlay();
      scanner.start();
    } else {
      scanner.stop();
    }
    notifyListeners();
  }

  // Store & existing shelf content
  int? _storeId;
  Set<int> alreadyOnShelf = <int>{};

  // Selected products to insert {productId: name}
  final Map<int, String> selected = {};

  // Search
  final TextEditingController searchCtrl = TextEditingController();
  bool searching = false;
  List<SearchResult> results = const [];

  // Scan
  final MobileScannerController scanner = MobileScannerController();
  Rect? _qrRect;                 // QR position on screen
  Rect? get qrRect => _qrRect;
  ProductLite? overlayProduct;

  // State
  bool saving = false;
  String? lastMessage;

  /* ─────────── INIT ─────────── */
  Future<void> init() async {
    _storeId = await CurrentStoreService.getCurrentStoreId();
    await _loadShelfExisting();
    notifyListeners();
  }

  Future<void> _loadShelfExisting() async {
    final rows = await _sb
        .from('shelf_place')
        .select('product_id')
        .eq('shelf_id', shelfId);

    alreadyOnShelf = rows.map<int>((e) => e['product_id'] as int).toSet();
  }

  /* ─────────── SEARCH ─────────── */
  void onQueryChanged(String q) {
    _debouncedSearch(q);
  }

  // simple debounce
  int _searchToken = 0;
  Future<void> _debouncedSearch(String q) async {
    final tok = ++_searchToken;
    searching = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 220));
    if (tok != _searchToken) return;

    results = await _search(q.trim());
    searching = false;
    notifyListeners();
  }

  Future<List<SearchResult>> _search(String q) async {
    if (_storeId == null) return const [];
    // 1) Tous les product_id vendus par ce store
    final idsRows = await _sb
        .from('priced_product')
        .select('product_id')
        .eq('store_id', _storeId!)
        .limit(800); // garde une borne

    final ids = idsRows.map<int>((e) => e['product_id'] as int).toSet().toList();
    if (ids.isEmpty) return const [];

    // 2) Cherche dans product parmi ces ids
    final base = _sb
        .from('product')
        .select('product_id, name')
        .inFilter('product_id', ids);

    final rows = q.isEmpty
        ? await base.limit(50)
        : await base.filter('name', 'ilike', '%$q%').limit(50);

    return rows.map<SearchResult>((e) {
      return SearchResult(
        productId: e['product_id'] as int,
        name: (e['name'] as String?) ?? 'Item ${e['product_id']}',
      );
    }).toList();
  }

  /* ─────────── ADD PRODUCT (common to search & scan) ─────────── */
  Future<AddOutcome> addProduct(int productId, String name) async {
    // déjà sur cette étagère ?
    if (alreadyOnShelf.contains(productId)) {
      return const AddOutcome.fail('Already on this shelf');
    }
    // déjà sélectionné ?
    if (selected.containsKey(productId)) {
      return const AddOutcome.fail('Already selected');
    }
    // Vérifie qu’il appartient au store
    if (_storeId == null) {
      return const AddOutcome.fail('No store selected');
    }
    final row = await _sb
        .from('priced_product')
        .select('product_id')
        .eq('store_id', _storeId!)
        .eq('product_id', productId)
        .maybeSingle();

    if (row == null) {
      return const AddOutcome.fail('This product is not sold by your store');
    }

    selected[productId] = name;
    notifyListeners();
    return const AddOutcome.added();
  }

  void removeSelected(int productId) {
    selected.remove(productId);
    notifyListeners();
  }

  /* ─────────── CONFIRM INSERT ─────────── */
  Future<bool> confirmInsert() async {
    if (selected.isEmpty) return false;

    saving = true;
    lastMessage = null;
    notifyListeners();

    try {
      String? email;
      try {
        final actor = await CurrentActorService.getCurrentActor();
        // ignore: invalid_use_of_protected_member
        final e = (actor as dynamic).email; // tolerant à l’absence d’email
        if (e is String) email = e;
      } catch (_) {}

      final now = DateTime.now().toUtc().toIso8601String();

      final payload = selected.keys.map((pid) {
        return {
          'shelf_id': shelfId,
          'product_id': pid,
          if (email != null) 'created_by': email,
          'created_at': now,
        };
      }).toList();

      await _sb.from('shelf_place').insert(payload);
      alreadyOnShelf.addAll(selected.keys);
      selected.clear();

      saving = false;
      notifyListeners();
      return true;
    } catch (e) {
      lastMessage = 'Insert error: $e';
      saving = false;
      notifyListeners();
      return false;
    }
  }

  /* ─────────── SCAN LOGIC (overlay with + button) ─────────── */

  // geometry helpers
  Rect? _rawRectFromBarcode(Barcode b) {
    final cs = b.corners;
    if (cs.isEmpty) return null;
    double minX = cs.first.dx, minY = cs.first.dy;
    double maxX = cs.first.dx, maxY = cs.first.dy;
    for (final o in cs) {
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

  bool _busy = false;
  String? _lastRaw;
  DateTime _lastTime = DateTime.now();

  Future<void> onDetect(
      BarcodeCapture capture,
      BuildContext context, {
        required Size previewSize,
        BoxFit boxFit = BoxFit.cover,
      }) async {
    if (_busy) return;

    // position overlay
    if (capture.barcodes.isNotEmpty) {
      final b = capture.barcodes.first;
      final rr = _rawRectFromBarcode(b);
      if (rr != null && capture.size != null) {
        _qrRect = _mapImageRectToPreview(rr, capture.size!, previewSize, boxFit);
        notifyListeners();
      }
    }

    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw == null) continue;

      // throttle
      final now = DateTime.now();
      if (raw == _lastRaw && now.difference(_lastTime) < const Duration(milliseconds: 500)) {
        continue;
      }
      _lastRaw = raw;
      _lastTime = now;

      try {
        final data = jsonDecode(raw);
        if (data is! Map) continue;
        if (data['type'] != 'product') continue;
        final int? pid = data['product_id'] as int?;
        if (pid == null) continue;

        _busy = true;

        // fetch name for overlay
        final p = await _sb
            .from('product')
            .select('name')
            .eq('product_id', pid)
            .maybeSingle();

        overlayProduct = ProductLite(pid, p?['name'] as String?);
        notifyListeners();
      } catch (_) {
        // ignore
      } finally {
        _busy = false;
      }
      break;
    }
  }

  void clearOverlay() {
    overlayProduct = null;
    _qrRect = null;
    notifyListeners();
  }

  @override
  void dispose() {
    scanner.dispose();
    searchCtrl.dispose();
    super.dispose();
  }
}
