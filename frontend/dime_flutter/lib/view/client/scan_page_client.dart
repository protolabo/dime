import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/scan_page_vm.dart';

import '../components/header_client.dart';
import '../components/nav_bar_client.dart';
import 'favorite_menu.dart';
import 'item_page_customer.dart';
import 'search_page_client.dart';

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
    final media = MediaQuery.of(context);

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Header(null),
      ),
      body: Stack(
        children: [
          Container(color: Colors.white),
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
          ),

          // overlays empilés depuis le bas (on passe le context)
          ..._buildStackedOverlays(context, vm, media),
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

  List<Widget> _buildStackedOverlays(BuildContext context, ScanPageVM vm, MediaQueryData media) {
    final baseBottom = media.padding.bottom + 16.0;
    final spacing = 8.0;
    final List<Widget> widgets = [];
    final keys = vm.stackKeys;
    final screenW = media.size.width;
    final screenH = media.size.height;
    final margin = 8.0;
    final minTop = media.padding.top + margin;
    final maxBottom = screenH - media.padding.bottom - margin;

    final List<Rect> placedRects = [];
    int stackCount = 0;

    bool collides(Rect r) => placedRects.any((p) => p.overlaps(r));

    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      final data = vm.overlays[key];
      if (data == null) continue;

      double estHeight;
      Widget child;
      if (data['kind'] == 'product') {
        estHeight = 100.0;
        child = _buildProductOverlayFromDataPlaceholder(context, vm, key, data);
      } else {
        final items = (data['items'] as List).cast<ShelfItemVM>();
        final previewMax = 5;
        final rows = items.length < previewMax ? items.length : previewMax;
        estHeight = (56.0 * rows + 80.0)
            .clamp(140.0, MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height * .55);
        child = _buildShelfOverlayFromDataPlaceholder(context, vm, key, data);
      }

      final qr = vm.qrRectFor(key);
      bool placed = false;

      if (qr != null) {
        final maxAllowed = screenW - 32.0;
        final double overlayWidth = math.min(maxAllowed, math.max(qr.width, 280.0));
        final left = ((screenW - overlayWidth) / 2.0).clamp(8.0, screenW - overlayWidth - 8.0).toDouble();

        // 1) tentative au‑dessus
        double top = qr.top - estHeight - margin;
        if (top >= minTop) {
          final candidate = Rect.fromLTWH(left, top, overlayWidth, estHeight);
          if (!collides(candidate) && candidate.bottom <= maxBottom) {
            widgets.add(Positioned(
              left: left,
              top: top,
              width: overlayWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: estHeight),
                child: SizedBox(height: estHeight, child: child),
              ),
            ));
            placedRects.add(candidate);
            placed = true;
          }
        }

        // 2) sinon en dessous
        if (!placed) {
          final top2 = qr.bottom + margin;
          final candidate2 = Rect.fromLTWH(left, top2, overlayWidth, estHeight);
          if (top2 + estHeight <= maxBottom && !collides(candidate2)) {
            widgets.add(Positioned(
              left: left,
              top: top2,
              width: overlayWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: estHeight),
                child: SizedBox(height: estHeight, child: child),
              ),
            ));
            placedRects.add(candidate2);
            placed = true;
          }
        }
      }


      // 3) fallback: pile en bas (évite toute superposition)
      if (!placed) {
        final bottomVal = baseBottom + stackCount * (estHeight + spacing);
        final leftPad = data['kind'] == 'product' ? 20.0 : 16.0;
        final rightPad = leftPad;
        final width = screenW - leftPad - rightPad;
        final topY = screenH - (bottomVal + estHeight);
        widgets.add(Positioned(
          bottom: bottomVal,
          left: leftPad,
          right: rightPad,
          child: SizedBox(height: estHeight, child: child),
        ));
        placedRects.add(Rect.fromLTWH(leftPad, topY, width, estHeight));
        stackCount++;
      }
    }
    return widgets;
  }



  Widget _buildProductOverlayFromDataPlaceholder(BuildContext context, ScanPageVM vm, String key, Map<String, dynamic> data) {
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
                      vm.clearOverlay(key);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ItemPageCustomer(productId: pid)),
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
                ]
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => vm.clearOverlay(key)),
        ],
      ),
    );
  }

  Widget _buildShelfOverlayFromDataPlaceholder(BuildContext context, ScanPageVM vm, String key, Map<String, dynamic> data) {
    final List<ShelfItemVM> items = (data['items'] as List).cast<ShelfItemVM>();
    final previewMax = 5;
    final visible = items.length <= previewMax ? items : items.take(previewMax).toList();

    final decoration = BoxDecoration(
      color: Colors.black.withOpacity(0.75),
      borderRadius: AppRadius.border,
    );

    final compactMaxHeight =
    (56.0 * visible.length + 80.0).clamp(140.0, MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height * .55);

    final listWidget = ListView.separated(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (ctx, i) => _shelfItemTilePlaceholder(ctx, vm, visible[i]),
      separatorBuilder: (_, __) => const Divider(color: Colors.white12, height: 1),
      itemCount: visible.length,
    );

    return Container(
      padding: AppPadding.all,
      decoration: decoration,
      child: SafeArea(
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data['shelfName'] as String? ?? 'Shelf',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => vm.clearOverlay(key),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (items.isEmpty)
              Text('Aucun produit sur cette étagère',
                  style: AppTextStyles.body.copyWith(color: Colors.white70))
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: compactMaxHeight),
                child: listWidget,
              ),
            if (items.length > visible.length)
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

  Widget _shelfItemTilePlaceholder(BuildContext context, ScanPageVM vm, ShelfItemVM it) {
    final price = it.price;
    final promo = it.promoPrice;

    return InkWell(
      onTap: () {
        vm.clearOverlay(); // ferme tous ou spécifier key si besoin
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
