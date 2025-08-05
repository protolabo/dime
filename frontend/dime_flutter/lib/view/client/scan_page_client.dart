import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dime_flutter/view/styles.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dime_flutter/view/components/header.dart';
import 'package:dime_flutter/view/components/navbar_scanner.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';
import 'package:dime_flutter/view/client/item_page_customer.dart';
import 'package:dime_flutter/vm/current_store.dart';
import 'package:dime_flutter/view/client/search_page.dart';

class ScanClientPage extends StatefulWidget {
  const ScanClientPage({super.key});

  @override
  State<ScanClientPage> createState() => _ScanClientPageState();
}

class _ScanClientPageState extends State<ScanClientPage> {
  final _scanner = MobileScannerController();
  final _sb = Supabase.instance.client;

  Map<String, dynamic>? _overlayData; // {id, name, amount}
  String? _lastRaw;
  DateTime _lastTime = DateTime.now();

  /* ─────────── SCAN CALLBACK ─────────── */
  Future<void> _onDetect(BarcodeCapture capture) async {
    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw == null) continue;

      // anti-spam : même QR <= 2 s → ignore
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

        /*  QR formats attendus :
            { "type":"product", "product_id":42 }
            { "type":"shelf"  , "shelf_id"  :17 }
        */
        switch (data['type']) {
          case 'product':
            await _handleProduct(data['product_id'] as int);
            break;
          case 'shelf':
            // TODO: gérer l’affichage d’une étagère si besoin
            break;
        }
      } catch (_) {
        // QR non reconnu → on ignore
      }
    }
  }

  /* ─────────── RECUP PRODUIT + PRIX ─────────── */
  Future<void> _handleProduct(int id) async {
    final int? storeId = await CurrentStoreService.getCurrentStoreId();
    if (storeId == null) return;

    try {
      // 1 nom du produit
      final product = await _sb
          .from('product')
          .select('name')
          .eq('product_id', id)
          .maybeSingle();

      // 2 prix dans CE magasin (colonne amount)
      final priceRow = await _sb
          .from('priced_product')
          .select('amount, currency')
          .eq('product_id', id)
          .eq('store_id', storeId)
          .maybeSingle();

      if (product != null) {
        setState(() {
          _overlayData = {
            'id': id,
            'name': product['name'],
            'amount': priceRow?['amount'],
            'currency': priceRow?['currency'] ?? '\$',
          };
        });
      }
    } catch (_) {
      // log si besoin
    }
  }

  /* ─────────── UI ─────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Header(null),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _scanner, onDetect: _onDetect),
          if (_overlayData != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: _buildOverlayCard(),
            ),
        ],
      ),
      bottomNavigationBar: NavBar_Scanner(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoriteMenuPage()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildOverlayCard() {
    final num? amount = _overlayData!['amount'] as num?;
    final String currency = _overlayData!['currency'] as String? ?? '\$';

    return Container(
      padding: AppPadding.all,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: AppRadius.border,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /* ───── nom de l’item (cliquable) ───── */
                GestureDetector(
                  onTap: () {
                    final pid = _overlayData?['id'] as int?;
                    if (pid != null) {
                      setState(() => _overlayData = null); // cache l’overlay
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemPageCustomer(productId: pid),
                        ),
                      );
                    }
                  },
                  child: Text(
                    _overlayData!['name'] ?? 'Item inconnu',
                    style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount != null
                      ? '${amount.toStringAsFixed(2)} $currency'
                      : 'Prix —',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _overlayData = null),
          ),
        ],
      ),
    );
  }
}
