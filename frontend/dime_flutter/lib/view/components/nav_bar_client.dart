import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/components/nav_bar_client_vm.dart';

/// Floating bottom navigation bar for **client** side.
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

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.favorite_border,
              label: 'Favorite',
              isSelected: vm.currentIndex == 0,
              onTap: () {
                vm.setIndex(0);
                onTap(0);
              },
            ),
            _NavItem(
              icon: Icons.qr_code_scanner,
              label: 'Search',
              isSelected: vm.currentIndex == 1,
              onTap: () {
                vm.setIndex(1);
                onTap(1);
              },
            ),
            _NavItem(
              icon: Icons.history,
              label: 'History',
              isSelected: vm.currentIndex == 2,
              hasNotification: false,
              onTap: () {
                vm.setIndex(2);
                onTap(2);
              },
            ),
            _NavItem(
              icon: Icons.search,
              label: 'Search',
              isSelected: vm.currentIndex == 3,
              onTap: () {
                vm.setIndex(3);
                onTap(3);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/*───────────────────────────────────────────*/

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.hasNotification = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hasNotification;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.white.withOpacity(0.0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 28,
                ),
                if (widget.hasNotification)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4B6E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2D2D2D),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: widget.isSelected
                  ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}