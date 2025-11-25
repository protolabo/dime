import 'package:dime_flutter/view/commercant/myTeam.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/commercant/create_qr_menu_vm.dart';

import 'scan_page_commercant.dart';
import 'search_page_commercant.dart';

class CreateQrMenuPage extends StatelessWidget {
  const CreateQrMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateQrMenuViewModel(),
      child: Consumer<CreateQrMenuViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const HeaderCommercant(),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Nom du magasin avec icône
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.store,
                            size: 48,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          vm.isLoading ? '...' : (vm.storeName ?? '—'),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.title.copyWith(fontSize: 24),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Titre de section
                  Text(
                    'Gestion du magasin',
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),

                  const SizedBox(height: 16),

                  // Bouton Create Item
                  _ActionCard(
                    icon: Icons.add_shopping_cart,
                    title: 'Créer un article',
                    subtitle: 'Ajouter un nouvel article au magasin',
                    color: Colors.blue[50]!,
                    iconColor: Colors.blue[700]!,
                    onTap: () => vm.goToCreateItem(context),
                  ),

                  const SizedBox(height: 12),

                  // Bouton Create Shelf
                  _ActionCard(
                    icon: Icons.grid_view_rounded,
                    title: 'Créer une étagère',
                    subtitle: 'Organiser les articles par étagère',
                    color: Colors.green[50]!,
                    iconColor: Colors.green[700]!,
                    onTap: () => vm.goToCreateShelf(context),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
            bottomNavigationBar: navbar_commercant(
              currentIndex: 0,
              onTap: (i) {
                if (i == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanCommercantPage()),
                  );
                } else if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageTeamPage()),
                  );
                } else if (i == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPageCommercant()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

/* ──────────── ACTION CARD ──────────── */
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
