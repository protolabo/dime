import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/commercant/search_commercant_vm.dart';

import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/view/commercant/scan_page_commercant.dart';
import 'package:dime_flutter/view/commercant/create_qr_menu.dart';
import 'package:dime_flutter/view/commercant/shelf_page.dart';

import 'item_commercant.dart';
import 'myTeam.dart';

class SearchPageCommercant extends StatelessWidget {
  const SearchPageCommercant({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchCommercantVM()..bootstrap(),
      child: const _SearchCommercantBody(),
    );
  }
}

class _SearchCommercantBody extends StatelessWidget {
  const _SearchCommercantBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchCommercantVM>();

    return Scaffold(
      backgroundColor: AppColors.searchBg,
      appBar: const HeaderCommercant(),
      bottomNavigationBar: navbar_commercant(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateQrMenuPage()),
            );
          }
          else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageTeamPage()),
            );
          }else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanCommercantPage()),
            );
          }
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _SearchBar(
              controller: vm.searchController,
              onChanged: vm.onQueryChanged,
              enabled: vm.storeId != null,
              hintText: vm.storeId == null
                  ? "Sélectionne d'abord un commerce…"
                  : "Rechercher un produit ou une étagère…",
            ),
            SizedBox(height: AppSpacing.lg),
            if (vm.isLoading)
              const Center(child: CircularProgressIndicator()),
            if (!vm.isLoading && vm.storeId != null)
              const Expanded(child: _ResultsList()),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.enabled,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      style: AppTextStyles.input,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchCommercantVM>();
    final hasAny = vm.products.isNotEmpty || vm.shelves.isNotEmpty;

    if (!hasAny) {
      return Center(
        child: Text("Aucun résultat", style: AppTextStyles.muted),
      );
    }

    return ListView(
      children: [
        if (vm.products.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text("Produits", style: AppTextStyles.sectionTitle),
          ),
          ...vm.products.map((p) => _ProductTile(p)),
          SizedBox(height: AppSpacing.lg),
        ],
        if (vm.shelves.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text("Étagères", style: AppTextStyles.sectionTitle),
          ),
          ...vm.shelves.map((s) => _ShelfTile(s)),
        ],
      ],
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile(this.p);
  final ProductResult p;

  String _priceText() {
    if (p.amount == null) return "—";
    final unit = (p.pricingUnit ?? '').trim();
    final cur = (p.currency ?? '').trim();
    if (unit.isEmpty && cur.isEmpty) return '${p.amount}';
    if (unit.isEmpty) return '${p.amount} $cur';
    if (cur.isEmpty) return '${p.amount} / $unit';
    return '${p.amount} $cur / $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: p.imageUrl != null && p.imageUrl!.isNotEmpty
            ? Image.network(p.imageUrl!, width: 48, height: 48, fit: BoxFit.cover)
            : const Icon(Icons.inventory_2_outlined),
        title: Text(p.name, style: AppTextStyles.itemTitle),
        subtitle: (p.barCode == null || p.barCode!.isEmpty)
            ? null
            : Text('Code-barres: ${p.barCode}', style: AppTextStyles.secondary),
        trailing: Text(_priceText(), style: AppTextStyles.price),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemCommercantPage(productId: p.productId, productName: p.name),
            ),
          );
          if (result == true) {
            final vm = Provider.of<SearchCommercantVM>(context, listen: false);
            await vm.search(vm.lastQuery);
          }
        }
,
      ),
    );
  }
}

class _ShelfTile extends StatelessWidget {
  const _ShelfTile(this.s);
  final ShelfResult s;

  @override
  Widget build(BuildContext context) {
    final subtitle = (s.location == null || s.location!.isEmpty)
        ? null
        : Text('Location: ${s.location}', style: AppTextStyles.secondary);

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: const Icon(Icons.qr_code_2),
        title: Text(s.name, style: AppTextStyles.itemTitle),
        subtitle: subtitle,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShelfPageCommercant(
                shelfId: s.shelfId,
                shelfName: s.name, // <- requis par ton ShelfPage
              ),
            ),
          );
        },
      ),
    );
  }
}