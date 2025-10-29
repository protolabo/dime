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
import 'item_commercant.dart';


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

          // overlays empilés depuis le bas
          ..._buildStackedOverlays(context, vm, media),
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

  List<Widget> _buildStackedOverlays(BuildContext context, ScanPageVM vm, MediaQueryData media) {
    final baseBottom = media.padding.bottom + 16.0;
    final spacing = 8.0;
    final List<Widget> widgets = [];
    final keys = vm.stackKeys;
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      final data = vm.overlays[key];
      if (data == null) continue;

      double estHeight;
      Widget child;
      if (data['kind'] == 'product') {
        estHeight = 100.0;
        child = _buildProductOverlayFromDataPlaceholder(context, vm, key, data);
        widgets.add(Positioned(
          bottom: baseBottom + i * (estHeight + spacing),
          left: 20,
          right: 20,
          child: child,
        ));
      } else if (data['kind'] == 'shelf') {
        final items = (data['items'] as List).cast<ShelfItemVM>();
        final previewMax = 5;
        final rows = items.length < previewMax ? items.length : previewMax;
        estHeight = 56.0 * rows + 80.0;
        child = _buildShelfOverlayFromDataPlaceholder(context, vm, key, data);
        widgets.add(Positioned(
          bottom: baseBottom + i * (estHeight + spacing),
          left: 16,
          right: 16,
          child: child,
        ));
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
                    final p_name = data['name'];
                    if (pid != null) {
                      vm.clearOverlay(key);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ItemCommercantPage(productId: pid, productName: p_name,)),
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
    final items = (data['items'] as List).cast<ShelfItemVM>();
    final list = items.length <= 5 ? items : items.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.80),
        borderRadius: AppRadius.border,
      ),
      padding: AppPadding.all,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final name = data['shelfName'] ?? 'Shelf';
                    vm.clearOverlay(key);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShelfPageCommercant(
                          shelfName: name,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    data['shelfName'] ?? 'Shelf',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                    ),
                  ),
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
            Text('Aucun item trouvé sur cette étagère',
                style: AppTextStyles.body.copyWith(color: Colors.white70))
          else ...[
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (ctx, i) => _shelfItemTilePlaceholder(ctx, vm, list[i]),
              ),
            ),
            if (items.length > list.length)
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

  Widget _shelfItemTilePlaceholder(BuildContext context, ScanPageVM vm, ShelfItemVM it) {
    final price = it.price;
    final promo = it.promoPrice;

    return InkWell(
      onTap: () {
        vm.clearOverlay();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemCommercantPage(productId: it.productId, productName: it.name,)),
        );
      },
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
