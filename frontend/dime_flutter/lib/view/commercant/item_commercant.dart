import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/view/commercant/shelf_page.dart';
import 'package:dime_flutter/vm/commercant/item_commercant_vm.dart';

import 'create_qr_menu.dart';
import 'scan_page_commercant.dart';
import 'search_page_commercant.dart';

class ItemCommercantPage extends StatelessWidget {
  const ItemCommercantPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  final int productId;
  final String productName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemCommercantVM(
        productId: productId,
        initialProductName: productName,
      )..init(),
      child: const _ItemBody(),
    );
  }
}

class _ItemBody extends StatefulWidget {
  const _ItemBody({super.key});

  @override
  State<_ItemBody> createState() => _ItemBodyState();
}

class _ItemBodyState extends State<_ItemBody> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemCommercantVM>();
    final String title = (vm.productName ?? vm.initialProductName);

    // Sync champs
    if (_nameCtrl.text.isEmpty && (vm.productName ?? '').isNotEmpty) {
      _nameCtrl.text = vm.productName!;
    }
    if (_priceCtrl.text.isEmpty && vm.price != null) {
      _priceCtrl.text = vm.price!.toStringAsFixed(2);
    }

    return Scaffold(
      appBar: const HeaderCommercant(),
      bottomNavigationBar: navbar_commercant(
        currentIndex: 0, // My Commerce
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQrMenuPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanCommercantPage()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPageCommercant()));
          }
        },
      ),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back + delete
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
                    tooltip: 'Remove this item from the current store',
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove item from store?'),
                          content: const Text(
                            'This will delete its price in this store and remove it from all shelves of this store. The product itself will not be deleted from the global catalog.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );

                      if (ok == true && context.mounted) {
                        final success = await vm.removeFromCurrentStore();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success ? 'Item removed from this store.' : (vm.errorMessage ?? 'Failed to remove item.'),
                            ),
                          ),
                        );
                        if (success) Navigator.of(context).maybePop();
                      }
                    },
                  ),
                ],
              ),

              // Titre
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.title,
                ),
              ),

              const SizedBox(height: 12),

              // Edition (nom + prix)
              Text('Edit item', style: AppTextStyles.subtitle),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.searchBg,
                  borderRadius: AppRadius.border,
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Name
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Item name',
                              filled: true,
                              fillColor: AppColors.inputBg,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await vm.updateName(_nameCtrl.text);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(vm.errorMessage ?? 'Name updated.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.border),
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Price
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Regular price',
                              suffixText: 'CAD',
                              filled: true,
                              fillColor: AppColors.inputBg,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final txt = _priceCtrl.text.replaceAll(',', '.');
                            final amt = double.tryParse(txt);
                            if (amt == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid price')),
                              );
                              return;
                            }
                            await vm.updatePrice(amt, currencyCode: vm.currency ?? 'CAD');
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(vm.errorMessage ?? 'Price updated.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: AppRadius.border),
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description (read-only si dispo)
              if ((vm.description ?? '').trim().isNotEmpty) ...[
                Text('Description', style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.searchBg,
                    borderRadius: AppRadius.border,
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    vm.description!,
                    style: AppTextStyles.body,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Shelves
              Text('Shelves with this item', style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.searchBg,
                  borderRadius: AppRadius.border,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: vm.shelves.isEmpty
                      ? [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('This item is not on any shelf in this store.', style: AppTextStyles.body),
                    )
                  ]
                      : vm.shelves.map((s) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShelfPageCommercant(
                              shelfName: s.name,
                              shelfId: s.shelfId,
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(child: Text(s.name, style: AppTextStyles.body)),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Download QR
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    await vm.downloadItemQrPdf();
                    if (!context.mounted) return;
                    if (vm.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(vm.errorMessage!)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.border),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Download QR code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
