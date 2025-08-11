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
          // Caméra visible par défaut ; on la retire seulement si étagère plein écran
          if (!(vm.kind == ScanOverlayKind.shelf && vm.expanded))
            MobileScanner(
              controller: vm.scanner,
              onDetect: (capture) => vm.onDetect(capture, context),
            )
          else
            Container(color: Colors.black),

          // Overlay produit
          if (vm.kind == ScanOverlayKind.product)
            Positioned(
              bottom: 40, left: 20, right: 20,
              child: _buildProductOverlay(context, vm),
            ),

          // Overlay étagère (compact ou plein écran)
          if (vm.kind == ScanOverlayKind.shelf)
            Positioned(
              top: vm.expanded ? 0 : null,
              bottom: vm.expanded ? 0 : 20,
              left: vm.expanded ? 0 : 16,
              right: vm.expanded ? 0 : 16,
              child: _buildShelfOverlay(context, vm),
            ),
        ],
      ),
      bottomNavigationBar: navbar_client(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteMenuPage()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
          }
        },
      ),
    );
  }

  /* ---------- Overlay PRODUIT ---------- */
  Widget _buildProductOverlay(BuildContext context, ScanPageVM vm) {
    final data = vm.overlayData!;
    final num? amount = data['amount'] as num?;
    final String currency = data['currency'] as String? ?? '\$';
    final num? promo = data['promo'] as num?;

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
                GestureDetector(
                  onTap: () {
                    final pid = data['id'] as int?;
                    if (pid != null) {
                      vm.clearOverlay();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemPageCustomer(productId: pid),
                        ),
                      );
                    }
                  },
                  child: Text(
                    data['name'] ?? 'Item inconnu',
                    style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                if (promo != null) ...[
                  Text(
                    '${(amount ?? 0).toStringAsFixed(2)} $currency',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white54,
                      decoration: TextDecoration.lineThrough,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${promo.toStringAsFixed(2)} $currency',
                    style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                  ),
                ] else ...[
                  Text(
                    amount != null ? '${amount.toStringAsFixed(2)} $currency' : 'Prix —',
                    style: AppTextStyles.body.copyWith(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: vm.clearOverlay),
        ],
      ),
    );
  }

  /* ---------- Overlay ÉTAGÈRE ---------- */
  Widget _buildShelfOverlay(BuildContext context, ScanPageVM vm) {
    final items = vm.shelfItems;
    final previewMax = 5;
    final visible = vm.expanded ? items : items.take(previewMax).toList();

    final decoration = BoxDecoration(
      color: Colors.black.withOpacity(vm.expanded ? 0.92 : 0.75),
      borderRadius: vm.expanded ? BorderRadius.zero : AppRadius.border,
    );

    // Hauteur utilisable en compact (évite Expanded/Flexible avec hauteur non bornée)
    final compactMaxHeight = 56.0 * visible.length + 80.0; // 56/row + header approx
    final constrained = compactMaxHeight.clamp(140.0, MediaQuery.of(context).size.height * .55);

    final listWidget = ListView.separated(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: vm.expanded ? false : true,
      itemBuilder: (_, i) => _shelfItemTile(context, vm, visible[i]),
      separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
      itemCount: visible.length,
    );

    return Container(
      padding: vm.expanded ? const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 12) : AppPadding.all,
      decoration: decoration,
      child: SafeArea(
        bottom: true,
        child: Column(
          mainAxisSize: vm.expanded ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vm.shelfName ?? 'Shelf',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(vm.expanded ? Icons.close_fullscreen : Icons.open_in_full, color: Colors.white),
                  tooltip: vm.expanded ? 'Réduire' : 'Agrandir',
                  onPressed: vm.toggleExpanded,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: vm.clearOverlay,
                ),
              ],
            ),
            const SizedBox(height: 6),

            if (items.isEmpty)
              Text('Aucun produit sur cette étagère',
                  style: AppTextStyles.body.copyWith(color: Colors.white70))
            else
              (vm.expanded)
                  ? Expanded(child: listWidget) // plein écran → on peut utiliser Expanded
                  : ConstrainedBox(            // compact → hauteur bornée
                constraints: BoxConstraints(maxHeight: constrained),
                child: listWidget,
              ),

            if (!vm.expanded && items.length > visible.length)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '+${items.length - visible.length} autres items — appuie pour agrandir',
                  style: AppTextStyles.body.copyWith(color: Colors.white60, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _shelfItemTile(BuildContext context, ScanPageVM vm, ShelfItemVM it) {
    final price = it.price;
    final promo = it.promoPrice;

    return InkWell(
      onTap: () {
        vm.clearOverlay();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemPageCustomer(productId: it.productId)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(child: Text(it.name, style: AppTextStyles.body.copyWith(color: Colors.white))),
            const SizedBox(width: 8),
            if (it.promoActive && promo != null) ...[
              Text(
                price != null ? '${price.toStringAsFixed(2)} ${it.currency}' : '',
                style: AppTextStyles.body.copyWith(
                    fontSize: 12, color: Colors.white54, decoration: TextDecoration.lineThrough),
              ),
              const SizedBox(width: 6),
              Text('${promo.toStringAsFixed(2)} ${it.currency}',
                  style: AppTextStyles.body.copyWith(color: Colors.white)),
            ] else
              Text(
                price != null ? '${price.toStringAsFixed(2)} ${it.currency}' : '—',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
