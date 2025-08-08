import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/components/nav_bar_client_vm.dart';

/// Barre de navigation du côté **client**.
///
/// ⚠️  **Interface inchangée** :
///   - `currentIndex` pour indiquer la page courante
///   - `onTap` pour déléguer la navigation aux vues appelantes
class navbar_client extends StatelessWidget {
  const navbar_client({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavBarClientVM(initialIndex: currentIndex),
      child: _NavBarView(onTap: onTap),
    );
  }
}

/*───────────────────────────────────────────*/

class _NavBarView extends StatelessWidget {
  const _NavBarView({required this.onTap});
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavBarClientVM>();

    return BottomNavigationBar(
      currentIndex: vm.currentIndex,
      // ↳ Met à jour le VM *et* propage l’action à la vue parente
      onTap: (i) {
        vm.setIndex(i);
        onTap(i);
      },

      /* ─── Apparence (identique à l’original) ─── */
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.searchBg,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedIconTheme: const IconThemeData(size: 45),
      selectedLabelStyle:
      AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
      unselectedLabelStyle: AppTextStyles.body,

      /* ─── Items ─── */
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorite'),
        BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historic'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
    );
  }
}
