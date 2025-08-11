import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/scan_page_vm.dart';

import '../components/header_commercant.dart';
import '../components/nav_bar_commercant.dart';
import 'create_qr_menu.dart';
import 'shelf_page.dart';
import 'search_page_commercant.dart';

class ScanCommercantPage extends StatelessWidget {
  const ScanCommercantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScanPageVM(),
      child: const _ScanCommercantPageBody(),
    );
  }
}

class _ScanCommercantPageBody extends StatelessWidget {
  const _ScanCommercantPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScanPageVM>();
    final media = MediaQuery.of(context);

    return Scaffold(
      appBar: const HeaderCommercant(),
      body: Stack(
        children: [
          // Caméra visible par défaut ; retirée seulement si étagère plein écran
          if (!(vm.kind == ScanOverlayKind.shelf && vm.expanded))
            LayoutBuilder(
              builder: (context, constraints) {
                final previewSize = constraints.biggest;
                const fit = BoxFit.cover;
                return MobileScanner(
                  fit: fit,
                  controller: vm.scanner,
                  onDetect: (capture) => vm.onDetect(
                    capture,
                    context,
                    previewSize: previewSize,
                    boxFit: fit,
                  ),
                );
              },
            )
          else
            Container(color: Colors.black),

          // Overlay PRODUIT (sous le QR quand possible)
          if (vm.kind == ScanOverlayKind.product)
            Positioned(
              top: vm.qrRect != null
                  ? _clampTopForProduct(
                  media.size.height, media.padding, vm.qrRect!.bottom + 12)
                  : null,
              bottom: vm.qrRect == null ? 40 : null,
              left: 20,
              right: 20,
              child: _buildProductOverlay(context, vm),
            ),

          // Overlay ÉTAGÈRE (sous le QR en compact, plein écran si expand)
          if (vm.kind == ScanOverlayKind.shelf)
            Positioned(
              top: vm.expanded
                  ? 0
                  : (vm.qrRect != null
                  ? _clampTopForShelf(
                media.size.height,
                media.padding,
                vm.qrRect!.bottom + 12,
                vm.shelfItems,
              )
                  : null),
              bottom: vm.expanded ? 0 : (vm.qrRect == null ? 20 : null),
              left: vm.expanded ? 0 : 16,
              right: vm.expanded ? 0 : 16,
              child: _buildShelfOverlay(context, vm),
            ),
        ],
      ),
      bottomNavigationBar: navbar_commercant(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQrMenuPage()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPageCommercant()));
          }
        },
      ),
    );
  }

  // Empêche l’overlay produit de dépasser en bas
  double _clampTopForProduct(double screenH, EdgeInsets viewInsets, double desiredTop) {
    const estHeight = 100.0; // carte produit approx
    final maxTop = screenH - viewInsets.bottom - 16.0 - estHeight;
    return desiredTop.clamp(viewInsets.top + 16.0, maxTop);
  }

  // Empêche l’overlay étagère (compact) de dépasser en bas
  double _clampTopForShelf(
      double screenH,
      EdgeInsets viewInsets,
      double desiredTop,
      List<ShelfItemVM> items,
      ) {
    const previewMax = 5;
    final rows = items.length < previewMax ? items.length : previewMax;
    final estHeight = 56.0 * rows + 80.0; // rows + header/padding approx
    final maxTop = screenH - viewInsets.bottom - 16.0 - estHeight;
    return desiredTop.clamp(viewInsets.top + 16.0, maxTop);
  }

  /* ─────────── OVERLAY PRODUIT ─────────── */
  Widget _buildProductOverlay(BuildContext context, ScanPageVM vm) {
    final data = vm.overlayData; // ✅ nom correct dans le VM
    if (data == null) return const SizedBox.shrink();

    final num? amount = data['amount'] as num?;
    final String currency = data['currency'] as String? ?? '\$';
    final num? promo = data['promo'] as num?;

    return Container(
      padding: AppPadding.all,
      decoration: BoxDecoration(
        // Si .withValues indisponible sur ta version, remets .withOpacity(0.75)
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: AppRadius.border,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ⚠️ Commerçant : cliquer sur le nom NE FAIT RIEN
                Text(
                  data['name'] ?? 'Item inconnu',
                  style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
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
                ]
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: vm.clearOverlay),
        ],
      ),
    );
  }

  /* ─────────── OVERLAY ÉTAGÈRE ─────────── */
  Widget _buildShelfOverlay(BuildContext context, ScanPageVM vm) {
    final items = vm.shelfItems;
    final list = vm.expanded ? items : (items.length <= 5 ? items : items.take(5).toList());

    final listWidget = ListView.builder(
      shrinkWrap: !vm.expanded,
      physics: vm.expanded ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, i) => _shelfItemTile(context, vm, list[i]),
    );

    return Container(
      decoration: BoxDecoration(
        // Si .withValues indisponible, remets .withOpacity(0.80)
        color: Colors.black.withValues(alpha: 0.80),
        borderRadius: vm.expanded ? null : AppRadius.border,
      ),
      padding: vm.expanded ? const EdgeInsets.fromLTRB(16, 16, 16, 24) : AppPadding.all,
      child: Column(
        mainAxisSize: vm.expanded ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ⬇️ Nom d’étagère cliquable → ouvre ShelfPageCommercant
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final name = vm.shelfName ?? 'Shelf';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShelfPageCommercant(
                          shelfName: name,
                          // Si ton VM expose shelfId/qrData, passe-les ici:
                          // shelfId: vm.shelfId,
                          // qrData: vm.shelfQrData,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    vm.shelfName ?? 'Shelf',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
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
            Text('Aucun item trouvé sur cette étagère',
                style: AppTextStyles.body.copyWith(color: Colors.white70))
          else ...[
            if (vm.expanded)
              Expanded(child: listWidget)
            else
              Flexible(child: listWidget),

            if (!vm.expanded && items.length > list.length)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '+${items.length - list.length} autres items — appuie pour agrandir',
                  style: AppTextStyles.body.copyWith(color: Colors.white60, fontSize: 12),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _shelfItemTile(BuildContext context, ScanPageVM vm, ShelfItemVM it) {
    final price = it.price;
    final promo = it.promoPrice;

    // ⚠️ Commerçant : cliquer ne fait rien ici (la navigation se fait sur la page d’étagère)
    return InkWell(
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                it.name,
                style: AppTextStyles.body.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (it.promoActive && promo != null) ...[
              Text(
                price != null ? '${price.toStringAsFixed(2)} ${it.currency}' : '',
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: Colors.white54,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${promo.toStringAsFixed(2)} ${it.currency}',
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
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
