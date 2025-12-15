import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import '../../auth_viewmodel.dart';
import '../current_store.dart';
import '../current_connected_account_vm.dart';
final String apiBaseUrl = dotenv.env['BACKEND_API_URL'] ?? '';
enum AddItemMode { search, scan }

class ProductLite {
  final int id;
  final String? name;
  const ProductLite(this.id, this.name);
}

class SearchResult {
  final int productId;
  final String name;
  final String imageUrl ;
  const SearchResult({required this.productId, required this.name, required this.imageUrl});
}

class AddOutcome {
  final bool added;
  final String? reason;
  const AddOutcome.added() : added = true, reason = null;
  const AddOutcome.fail(this.reason) : added = false;
}

class AddItemToShelfVM extends ChangeNotifier {
  final AuthViewModel auth;
  AddItemToShelfVM({required this.shelfId, required this.shelfName, required this.auth});

  final int shelfId;
  final String shelfName;

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
    selected.clear();
    _storeId = await CurrentStoreService.getCurrentStoreId();
    await _loadShelfExisting();
    notifyListeners();
  }



  Future<void> _loadShelfExisting() async {
    final url = Uri.parse('$apiBaseUrl/shelf-places?shelf_id=$shelfId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final shelfPlaces = data['shelfPlaces'] as List<dynamic>;
      alreadyOnShelf = shelfPlaces.map<int>((e) => e['product_id'] as int).toSet();
    } else {
      alreadyOnShelf = {};
    }
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
    final url = Uri.parse('$apiBaseUrl/priced-products?store_id=$_storeId');
    var response = await http.get(url);
    print(response.body);
    print(response.statusCode);
    final idsRows;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pricedProducts = data['pricedProducts'] as List<dynamic>;
      idsRows = pricedProducts
          .map((e) => {'product_id': e['product_id']})
          .take(800)
          .toList();
    } else {
      idsRows = <Map<String, dynamic>>[];
    }
    final ids = idsRows.map<int>((e) => e['product_id'] as int).toSet().toList();
    if (ids.isEmpty) return const [];

    // 2) Cherche dans product parmi ces ids

    final uri = Uri.http(
      'localhost:3001',
      '/products',
      {'product_id': ids.map((id) => id.toString()).toList()},
    );
    response = await http.get(uri);
    print(uri);
    print(response.body);
    print(response.statusCode);
    List<dynamic> base = [];
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      //la clé de la réponse est `reviews` côté backend
      base = data['reviews'] as List<dynamic>;
    } else {
      base = [];
    }


    final rows = q.isEmpty
        ? base.take(50).toList()
        : base.where((e) =>
    (e['name'] as String?)?.toLowerCase().contains(q.toLowerCase()) ?? false
    ).take(50).toList();


    return rows.map<SearchResult>((e) {
      return SearchResult(
        productId: e['product_id'] as int,
        name: (e['name'] as String?) ?? 'Item ${e['product_id']}',
        imageUrl: (e['image_url'] as String?) ?? '',
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

    final url = Uri.parse('$apiBaseUrl/priced-products?store_id=$_storeId&product_id=$productId');
    final response = await http.get(url);
    Map<String, dynamic>? row;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final products = data['pricedProducts'] as List<dynamic>;
      row = products.isNotEmpty ? products.first as Map<String, dynamic> : null;
    } else {
      row = null;
    }

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
        final actor = await CurrentActorService.getCurrentActor(auth: auth);
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

      final url = Uri.parse('$apiBaseUrl/shelf-places');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      print(url);
      print( jsonEncode(payload));
      print(response.body);
      print(response.statusCode);
      if (response.statusCode != 201) {
        throw Exception('Error While Inserting: ${response.body}');
      }

      alreadyOnShelf.addAll(selected.keys);


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

    if (capture.barcodes.isNotEmpty) {
      final b = capture.barcodes.first;
      final rr = _rawRectFromBarcode(b);
      if (rr != null) {
        _qrRect = _mapImageRectToPreview(rr, capture.size, previewSize, boxFit);
        notifyListeners();
      }
    }

    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw == null) continue;

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

        final url = Uri.parse('$apiBaseUrl/products?product_id=$pid');
        final response = await http.get(url);
        Map<String, dynamic>? p;
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final products = data['reviews'] as List<dynamic>;
          p = products.isNotEmpty ? products.first as Map<String, dynamic> : null;
        } else {
          p = null;
        }
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
