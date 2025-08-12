import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/vm/commercant/shelf_page_vm.dart';

import 'add_item_to_shelf.dart';
import 'create_qr_menu.dart';
import 'scan_page_commercant.dart';
import 'search_page_commercant.dart';
import 'item_commercant.dart';

class ShelfPageCommercant extends StatelessWidget {
  const ShelfPageCommercant({
    super.key,
    required this.shelfName,
    this.shelfId,
    this.qrData,
  });

  final String shelfName;
  final int? shelfId;
  final String? qrData;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShelfPageVM(
        initialShelfName: shelfName,
        initialShelfId: shelfId,
        initialQrData: qrData,
      )..init(),
      child: const _ShelfPageBody(),
    );
  }
}

class _ShelfPageBody extends StatefulWidget {
  const _ShelfPageBody({super.key});
  @override
  State<_ShelfPageBody> createState() => _ShelfPageBodyState();
}

class _ShelfPageBodyState extends State<_ShelfPageBody> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShelfPageVM>();

    return Scaffold(
      appBar: const HeaderCommercant(),
      bottomNavigationBar: navbar_commercant(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQrMenuPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanCommercantPage()));
          }
          else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPageCommercant()));
          }
        },
      ),
      body: SafeArea(
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : vm.error != null
            ? _ErrorView(error: vm.error!)
            : _Content(
          vm: vm,
          expanded: _expanded,
          onToggleExpanded: () => setState(() => _expanded = !_expanded),
        ),
      ),
    );
  }


}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final String error;
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Erreur: $error', style: AppTextStyles.body));
}

class _Content extends StatelessWidget {
  const _Content({
    required this.vm,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final ShelfPageVM vm;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final name = vm.shelfName ?? vm.initialShelfName;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Go Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete / Edit shelf (à venir)',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Édition étagère à venir')),
                  );
                },
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(name, textAlign: TextAlign.center, style: AppTextStyles.title),
          ),

          const SizedBox(height: 12),

          Text('All items', style: AppTextStyles.subtitle),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: AppColors.searchBg,
              borderRadius: AppRadius.border,
              border: Border.all(color: AppColors.border),
              boxShadow: const [BoxShadow(blurRadius: 6, spreadRadius: 0.5, color: Colors.black12)],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Name',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Text(
                          'Price',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                ..._rows(context, vm, expanded),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onToggleExpanded,
                    child: Text(expanded ? 'Less items' : 'More items', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Center(
            child: ElevatedButton(
              onPressed: vm.downloadQrPdf, // ← utilise l’image BD
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Download QR Code'),
            ),
          ),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () async {
                // vm est déjà dispo dans ton build (Option A)
                final int? id = vm.shelfId;
                final String? rawName = vm.shelfName;

                if (id == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shelf not loaded yet')),
                  );
                  return;
                }

                final String name =
                (rawName == null || rawName.trim().isEmpty) ? 'Shelf #$id' : rawName.trim();

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddItemToShelfPage(
                      shelfId: id,           // int (non-null ici)
                      shelfName: name,       // String (non-null ici)
                    ),
                  ),
                );

                // Optionnel: rafraîchir la page d’étagère au retour
                // if (context.mounted) vm.reload();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add an item'),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _rows(BuildContext context, ShelfPageVM vm, bool expanded) {
    final all = vm.items;
    final list = expanded ? all : (all.length <= 8 ? all : all.take(8).toList());

    return list
        .map((it) => Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ItemCommercantPage(
                        productId: it.productId,
                        productName: it.name,
                      ),
                    ),
                  );
                },
                child: Text(
                  it.name,
                  style: AppTextStyles.body.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(
              width: 110,
              child: Text(
                it.price != null
                    ? '${it.price!.toStringAsFixed(2)} ${it.currency ?? ''}'
                    : '—',
                textAlign: TextAlign.right,
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(height: 1),
      ],
    ))
        .toList();
  }
}
