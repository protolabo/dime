import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dime_flutter/view/components/header.dart';
import 'package:dime_flutter/view/components/navbar_scanner.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';
import 'package:dime_flutter/vm/current_store.dart'; // pour récupérer l’id du magasin courant

class ScanClientPage extends StatefulWidget {
  const ScanClientPage({super.key});

  @override
  State<ScanClientPage> createState() => _ScanClientPageState();
}

class _ScanClientPageState extends State<ScanClientPage> {
  final _scanner = MobileScannerController();
  final _sb = Supabase.instance.client;

  Map<String, dynamic>? _overlayData; // {name, price}
  String? _lastRaw;
  DateTime _lastTime = DateTime.now();

  Future<void> _onDetect(BarcodeCapture capture) async {
    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw == null) continue;

      // anti-spam : ignore les doublons trop rapprochés
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

        /***
         * PRODUCT  → { type:'product', product_id:<int> }
         * SHELF    → { type:'shelf',   shelf_id:<int>   }
         */
        if (data['type'] == 'product') {
          await _handleProduct(data['product_id'] as int);
        } else if (data['type'] == 'shelf') {
          // tu pourrais naviguer vers la liste des produits de l’étagère, etc.
        }
      } catch (_) {
        // QR non reconnu
      }
    }
  }

  Future<void> _handleProduct(int id) async {
    final storeId =
        await CurrentStoreService.getCurrentStoreId(); // existe déjà dans ton projet

    // 1️⃣  nom du produit
    final product = await _sb
        .from('product')
        .select('name')
        .eq('product_id', id)
        .maybeSingle();

    // 2️⃣  prix (dans priced_product)
    final priceRow = await _sb
        .from('priced_product')
        .select('amount')
        .eq('product_id', id)
        .eq('store_id', storeId)
        .maybeSingle();

    if (product != null) {
      setState(() {
        _overlayData = {
          'name': product['name'],
          'price': priceRow != null ? priceRow['amount'] : null,
        };
      });
    }
  }

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
          }
        },
      ),
    );
  }

  Widget _buildOverlayCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _overlayData!['name'] ?? 'Item inconnu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _overlayData!['price'] != null
                      ? '${(_overlayData!['price'] as num).toStringAsFixed(2)} \$'
                      : 'Prix —',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
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
