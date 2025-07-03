import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanClientPage extends StatelessWidget {
  const ScanClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String nameCommerce =
        'nameCommerce'; // Remplace ceci par une valeur dynamique venant du backend plus tard

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Header(nameCommerce),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            print('📦 QR détecté: ${barcode.rawValue}');
          }
        },
      ),
      bottomNavigationBar: NavBar_Scanner(),
    );
  }

  BottomNavigationBar NavBar_Scanner() {
    return BottomNavigationBar(
      currentIndex: 1,
      backgroundColor: const Color(0xFFFDF1DC),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      selectedIconTheme: IconThemeData(size: 45), // Agrandit icône sélectionnée
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
      automaticallyImplyLeading: false, // pas de bouton retour par défaut
      backgroundColor: const Color(0xFFFFF2D9), // couleur beige
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Partie "Currently at"
          GestureDetector(
            onTap: () {
              print("Nom du commerce cliqué");
              // Tu peux afficher un modal ou autre ici
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
              // Navigator.pushReplacement or clear session
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
}
