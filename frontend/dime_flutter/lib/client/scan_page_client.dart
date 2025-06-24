import 'package:flutter/material.dart';

class ScanClientPage extends StatelessWidget {
  const ScanClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF2D9),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFFFEEC0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.settings, color: Colors.black),
                const SizedBox(width: 12),

                // --------- localisation bien centrée ----------
                const Icon(Icons.location_pin, color: Colors.red, size: 20),
                const SizedBox(width: 6),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        const TextSpan(text: 'Currently at: '),
                        TextSpan(
                          text: 'nameCommerce',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // ----------------------------------------------
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const Expanded(child: Center(child: Icon(Icons.qr_code, size: 120))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFEEC0),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historic'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}
