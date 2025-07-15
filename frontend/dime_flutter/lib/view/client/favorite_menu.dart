import 'package:flutter/material.dart';

// ───── Composants réutilisés ─────
import 'package:dime_flutter/view/components/header.dart';
import 'package:dime_flutter/view/components/navbar_scanner.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';

class FavoriteMenuPage extends StatefulWidget {
  const FavoriteMenuPage({super.key});

  @override
  State<FavoriteMenuPage> createState() => _FavoriteMenuPageState();
}

class _FavoriteMenuPageState extends State<FavoriteMenuPage> {
  @override
  Widget build(BuildContext context) {
    final bigTitleStyle = Theme.of(context).textTheme.headlineLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    final sectionTitleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Header(null), // ← Header dynamique grâce à Supabase
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('Favorites', style: bigTitleStyle)),
            const SizedBox(height: 32),

            Text('My favorite items', style: sectionTitleStyle),
            const SizedBox(height: 12),
            SizedBox(height: 120, child: Placeholder()),
            const SizedBox(height: 32),

            Text('My favorite commerces', style: sectionTitleStyle),
            const SizedBox(height: 12),
            SizedBox(height: 120, child: Placeholder()),
            const SizedBox(height: 32),

            Text('Recommended items', style: sectionTitleStyle),
            const SizedBox(height: 12),
            SizedBox(height: 120, child: Placeholder()),
            const SizedBox(height: 32),

            Text('Recommended commerces', style: sectionTitleStyle),
            const SizedBox(height: 12),
            SizedBox(height: 120, child: Placeholder()),
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
