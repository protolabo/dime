import 'package:flutter/material.dart';
import 'package:dime_flutter/view/styles.dart';

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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,

      /* ─── Apparence ─── */
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.searchBg,
      selectedItemColor: Colors.black, // même rendu qu’avant
      unselectedItemColor: Colors.black54,

      showSelectedLabels: true,
      showUnselectedLabels: true,

      selectedIconTheme: const IconThemeData(size: 45),
      selectedLabelStyle: AppTextStyles.body.copyWith(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: AppTextStyles.body,

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
