import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/commercant/create_qr_menu_vm.dart';

import 'myTeam.dart';
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
            backgroundColor: AppColors.background,
            appBar: const HeaderCommercant(),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Titre de la page
                    const Text(
                      'Créer un menu QR',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gérez votre catalogue de produits',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Encadré avec le nom du commerce
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey[50]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.card,
                        border: Border.all(color: Colors.grey[200]!, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.store_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Votre commerce',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vm.isLoading ? 'Chargement...' : (vm.storeName ?? 'Non défini'),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Boutons d'action
                    _buildActionButton(
                      context: context,
                      icon: Icons.add_shopping_cart_rounded,
                      title: 'Créer un article',
                      subtitle: 'Ajouter un nouveau produit',
                      onPressed: () => vm.goToCreateItem(context),
                    ),

                    const SizedBox(height: 16),

                    _buildActionButton(
                      context: context,
                      icon: Icons.shelves,
                      title: 'Créer une étagère',
                      subtitle: 'Organiser vos produits',
                      onPressed: () => vm.goToCreateShelf(context),
                      isPrimary: false,
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
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
                }
                else if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageTeamPage()),
                  );
                }else if (i == 4) {
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

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isPrimary ? AppColors.primary : Colors.grey).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isPrimary ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isPrimary ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isPrimary
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: isPrimary ? Colors.white : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
