import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


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
      if (raw == _lastRaw && now.difference(_lastTime) < const Duration(seconds: 2)) {
        continue;
      }
      _lastRaw = raw;
      _lastTime = now;

      try {
        final data = jsonDecode(raw);
        if (data['type'] == 'item') {
          setState(() => _currentItem = data);
        }
      } catch (_) {
        // invalid format, ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const String nameCommerce = 'nameCommerce'; // Il faudra changer cette ligne avec un élément du backend.

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Header(nameCommerce), // Header de l'app
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
          ),
          if (_currentItem != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: _buildItemCard(),
            ),
        ],
      ),
      bottomNavigationBar: NavBar_Scanner(), // Bar de navigation
    );
  }

  BottomNavigationBar NavBar_Scanner() {
    return BottomNavigationBar(
      currentIndex: 1,
      backgroundColor: const Color(0xFFFDF1DC),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      selectedIconTheme: IconThemeData(size: 45), // Agrandit icône sélectionnée pour qu'il soit plus visible
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.bold,
      ), // Texte plus visible
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorite'),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Scan',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historic'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
    );
  }
  AppBar Header(String nameCommerce) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFFFF2D9),
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Section de quel commerce qu'on est
          GestureDetector(
            onTap: () {
              print("Nom du commerce cliqué");
            },
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/address-icon.svg',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Currently at:',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    Text(
                      nameCommerce,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bouton logout
          GestureDetector(
            onTap: () {
              print("Logout cliqué");
            },
            child: SvgPicture.asset(
              'assets/icons/logout.svg',
              height: 28,
              width: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
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
                  '\$${(_currentItem!['price'] as num).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
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
