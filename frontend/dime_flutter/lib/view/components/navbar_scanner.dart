import 'package:flutter/material.dart';

class NavBar_Scanner extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBar_Scanner({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,

      // — Apparence générale —
      type: BottomNavigationBarType
          .fixed, // indispensable pour afficher tous les labels
      backgroundColor: const Color(0xFFFDF1DC),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,

      // — Affichage des labels —
      showSelectedLabels: true, // garde le label actif
      showUnselectedLabels: true, // … et les autres aussi
      // — Styles optionnels —
      selectedIconTheme: const IconThemeData(size: 45),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),

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
}
