import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../current_store.dart'; // service déjà existant

/// VM pour `ScanClientPage`.
///
/// — AUCUNE logique n’a été modifiée —
/// Tout le traitement qui se trouvait dans la page a simplement été déplacé
/// ici. La vue n’interagit qu’en lisant [overlayData], en appelant
/// [onDetect] et [clearOverlay].
class ScanPageVM extends ChangeNotifier {
  final MobileScannerController scanner = MobileScannerController();
  final SupabaseClient _sb = Supabase.instance.client;

  Map<String, dynamic>? _overlayData; // {id, name, amount, currency}
  Map<String, dynamic>? get overlayData => _overlayData;

  String? _lastRaw;
  DateTime _lastTime = DateTime.now();

  /* ─────────── SCAN CALLBACK ─────────── */
  Future<void> onDetect(BarcodeCapture capture, BuildContext context) async {
    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw == null) continue;

      // anti-spam : même QR ≤ 2 s → ignore
      final now = DateTime.now();
      if (raw == _lastRaw &&
          now.difference(_lastTime) < const Duration(seconds: 2)) {
        return;
      }
      _lastRaw = raw;
      _lastTime = now;

      try {
        final data = jsonDecode(raw);
        if (data is! Map) return;

        switch (data['type']) {
          case 'product':
            await _handleProduct(data['product_id'] as int);
            break;
          case 'shelf':
          // TODO : gérer l’affichage d’une étagère si besoin
            break;
        }
      } catch (_) {
        // QR non reconnu → on ignore
      }
    }
  }

  /* ─────────── RÉCUP PRODUIT + PRIX ─────────── */
  Future<void> _handleProduct(int id) async {
    final int? storeId = await CurrentStoreService.getCurrentStoreId();
    if (storeId == null) return;

    try {
      // 1. nom du produit
      final product = await _sb
          .from('product')
          .select('name')
          .eq('product_id', id)
          .maybeSingle();

      // 2. prix dans CE magasin (colonne amount)
      final priceRow = await _sb
          .from('priced_product')
          .select('amount, currency')
          .eq('product_id', id)
          .eq('store_id', storeId)
          .maybeSingle();

      if (product != null) {
        _overlayData = {
          'id': id,
          'name': product['name'],
          'amount': priceRow?['amount'],
          'currency': priceRow?['currency'] ?? '\$',
        };
        notifyListeners();
      }
    } catch (_) {
      // log si besoin
    }
  }

  /* ─────────── PUBLIC HELPERS ─────────── */
  void clearOverlay() {
    _overlayData = null;
    notifyListeners();
  }

  @override
  void dispose() {
    scanner.dispose();
    super.dispose();
  }
}
