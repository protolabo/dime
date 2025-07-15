import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dime_flutter/view/components/header.dart';
import 'package:dime_flutter/view/components/navbar_scanner.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';

class ScanClientPage extends StatefulWidget {
  const ScanClientPage({super.key});

  @override
  State<ScanClientPage> createState() => _ScanClientPageState();
}

class _ScanClientPageState extends State<ScanClientPage> {
  Map<String, dynamic>? _currentItem;
  final MobileScannerController _scanner = MobileScannerController();

  String? _lastRaw;
  DateTime _lastTime = DateTime.now();

  void _onDetect(BarcodeCapture capture) {
    for (final code in capture.barcodes) {
      final raw = code.rawValue;
      if (raw == null) continue;

      final now = DateTime.now();
      if (raw == _lastRaw &&
          now.difference(_lastTime) < const Duration(seconds: 2)) {
        continue;
      }
      _lastRaw = raw;
      _lastTime = now;

      try {
        final data = jsonDecode(raw);
        if (data['type'] == 'item') {
          setState(() => _currentItem = data);
        }
      } catch (_) {}
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
          if (_currentItem != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: _buildItemCard(),
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

  Widget _buildItemCard() {
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
                  _currentItem!['name'] ?? 'Item inconnu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_currentItem!['price'] as num).toStringAsFixed(2)}\$',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => setState(() => _currentItem = null),
          ),
        ],
      ),
    );
  }
}
