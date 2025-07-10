import 'package:flutter/material.dart';

// ───── Composants réutilisés ─────
import 'package:dime_flutter/view/components/header.dart';
import 'package:dime_flutter/view/components/navbar_scanner.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';

class FavoriteMenuPage extends StatelessWidget {
  const FavoriteMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    const nameCommerce = 'nameCommerce'; // Pour le backend

    // Styles rapides pour les titres
    final bigTitleStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    final sectionTitleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Header(nameCommerce),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───── Titre principal ─────
            Center(child: Text('Favorites', style: bigTitleStyle)),
            const SizedBox(height: 32),

            // ───── Section « My favorite items » ─────
            Text('My favorite items', style: sectionTitleStyle),
            const SizedBox(height: 12),
            // Remplace ceci par ton grid / carrousel
            SizedBox(
              height: 120,
              child: Placeholder(), // à remplacer
            ),
            const SizedBox(height: 32),

            // ───── Section « My favorite commerces » ─────
            Text('My favorite commerces', style: sectionTitleStyle),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Placeholder(), // à remplacer
            ),
            const SizedBox(height: 32),

            // ───── Section « Recommended items » ─────
            Text('Recommended items', style: sectionTitleStyle),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Placeholder(), // à remplacer
            ),
            const SizedBox(height: 32),

            // ───── Section « Recommended commerces » ─────
            Text('Recommended commerces', style: sectionTitleStyle),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: Placeholder(), // à remplacer
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: NavBar_Scanner(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanClientPage()),
            );
          }
        },
      ),
    );
  }
}
