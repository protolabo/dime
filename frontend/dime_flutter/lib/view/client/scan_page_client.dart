import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/client/scan_page_vm.dart';

import '../components/header_client.dart';
import '../components/nav_bar_client.dart';
import 'favorite_menu.dart';
import 'item_page_customer.dart';
import 'search_page.dart';

class ScanClientPage extends StatelessWidget {
  const ScanClientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanPageVM(),
      child: const _ScanClientPageBody(),
    );
  }
}

class _ScanClientPageBody extends StatelessWidget {
  const _ScanClientPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScanPageVM>();

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Header(null),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: vm.scanner,
            onDetect: (capture) => vm.onDetect(capture, context),
          ),
          if (vm.overlayData != null)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: _buildOverlayCard(context, vm),
            ),
        ],
      ),
        bottomNavigationBar: navbar_client(
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoriteMenuPage()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            }
          },
        )
    );
  }

  /* ─────────── OVERLAY CARD ─────────── */
  Widget _buildOverlayCard(BuildContext context, ScanPageVM vm) {
    final num? amount = vm.overlayData!['amount'] as num?;
    final String currency =
        vm.overlayData!['currency'] as String? ?? '\$';

    return Container(
      padding: AppPadding.all,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: AppRadius.border,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /* ───── nom de l’item (cliquable) ───── */
                GestureDetector(
                  onTap: () {
                    final pid = vm.overlayData?['id'] as int?;
                    if (pid != null) {
                      vm.clearOverlay(); // cache l’overlay
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemPageCustomer(productId: pid),
                        ),
                      );
                    }
                  },
                  child: Text(
                    vm.overlayData!['name'] ?? 'Item inconnu',
                    style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount != null
                      ? '${amount.toStringAsFixed(2)} $currency'
                      : 'Prix —',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: vm.clearOverlay,
          ),
        ],
      ),
    );
  }
}
