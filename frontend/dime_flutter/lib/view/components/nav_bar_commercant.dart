import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/components/nav_bar_commercant_vm.dart';

/// Barre de navigation du côté **commerçant**.
/// Interface identique à nav_bar_client:
///  - `currentIndex` indique l’onglet actif
///  - `onTap` délègue la navigation au parent
class navbar_commercant extends StatelessWidget {
  const navbar_commercant({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavBarCommercantVM(initialIndex: currentIndex),
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
    final vm = context.watch<NavBarCommercantVM>();

    return BottomNavigationBar(
      currentIndex: vm.currentIndex,
      onTap: (i) {
        vm.setIndex(i);
        onTap(i);
      },

      // Apparence alignée au client + couleurs de styles.dart
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

      // Items (ordre et libellés du prototype)
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'My Commerce'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Team'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
        BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Promotions'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
      ],
    );
  }
}
