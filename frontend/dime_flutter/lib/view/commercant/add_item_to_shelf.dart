import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/vm/commercant/add_item_to_shelf_vm.dart';
import '../../auth_viewmodel.dart';

class AddItemToShelfPage extends StatelessWidget {
  const AddItemToShelfPage({
    super.key,
    required this.shelfId,
    required this.shelfName,
  });

  final int shelfId;
  final String shelfName;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddItemToShelfVM(
        shelfId: shelfId,
        shelfName: shelfName,
        auth: context.read<AuthViewModel>(),
      )..init(),
      child: const _AddItemToShelfBody(),
    );
  }
}

class _AddItemToShelfBody extends StatelessWidget {
  const _AddItemToShelfBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddItemToShelfVM>();
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HeaderCommercant(),
      body: Column(
        children: [
          /* En-tête */
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                /* Back Button + Title */
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ajouter des articles',
                            style: AppTextStyles.title.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vm.shelfName,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /* Mode Toggle */
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModeButton(
                          label: 'Rechercher',
                          icon: Icons.search,
                          active: vm.mode == AddItemMode.search,
                          onTap: () => vm.setMode(AddItemMode.search),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ModeButton(
                          label: 'Scanner',
                          icon: Icons.qr_code_scanner,
                          active: vm.mode == AddItemMode.scan,
                          onTap: () => vm.setMode(AddItemMode.scan),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /* Content Area */
          Expanded(
            child: vm.mode == AddItemMode.search
                ? const _SearchArea()
                : _ScanArea(mediaPadding: media.padding),
          ),

          /* Footer avec articles sélectionnés */
          if (vm.selected.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /* Articles sélectionnés */
                  Row(
                    children: [
                      Text(
                        'Articles sélectionnés',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B7B8F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${vm.selected.length}',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8B7B8F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /* Bouton Confirmer */
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B7B8F),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: vm.saving
                          ? null
                          : () async {
                        final ok = await vm.confirmInsert();
                        if (!context.mounted) return;
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${vm.selected.length} article(s) ajouté(s)',
                              ),
                              backgroundColor: Colors.green[600],
                            ),
                          );
                          Navigator.of(context).pop(true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                vm.lastMessage ?? 'Erreur',
                              ),
                              backgroundColor: Colors.red[600],
                            ),
                          );
                        }
                      },
                      child: vm.saving
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Text(
                        'Ajouter ${vm.selected.length} article(s)',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/* ─────────── MODE BUTTON ─────────── */
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: active
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? const Color(0xFF8B7B8F) : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? Colors.black : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ─────────── SEARCH MODE ─────────── */
class _SearchArea extends StatelessWidget {
  const _SearchArea();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddItemToShelfVM>();

    return Column(
      children: [
        /* Barre de recherche */
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: vm.searchCtrl,
            onChanged: vm.onQueryChanged,
            style: AppTextStyles.body.copyWith(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Rechercher un article...',
              hintStyle: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),

        /* Résultats */
        Expanded(
          child: vm.searching
              ? const Center(child: CircularProgressIndicator())
              : vm.results.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucun résultat',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vm.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = vm.results[i];
              final isSelected = vm.selected.containsKey(r.productId);
              final isOnShelf = vm.alreadyOnShelf.contains(r.productId);

              return Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8B7B8F).withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B7B8F)
                        : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: isOnShelf
                      ? null
                      : () async {
                    if (isSelected) {
                      vm.removeSelected(r.productId);
                    } else {
                      final res = await vm.addProduct(
                        r.productId,
                        r.name,
                      );
                      if (!context.mounted) return;
                      if (!res.added) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              res.reason ?? 'Erreur',
                            ),
                            backgroundColor: Colors.orange[600],
                          ),
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            r.name,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOnShelf)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Déjà ajouté',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        else
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: isSelected
                                ? const Color(0xFF8B7B8F)
                                : Colors.grey[400],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ─────────── SCAN MODE ─────────── */
class _ScanArea extends StatelessWidget {
  const _ScanArea({required this.mediaPadding});
  final EdgeInsets mediaPadding;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AddItemToShelfVM>();

    return Stack(
      children: [
        /* Scanner */
        MobileScanner(
          controller: vm.scanner,
          onDetect: (capture) {
            final size = MediaQuery.of(context).size;
            vm.onDetect(
              capture,
              context,
              previewSize: size,
              boxFit: BoxFit.cover,
            );
          },
        ),


        /* Overlay produit scanné */
        if (vm.overlayProduct != null && vm.qrRect != null)
          Positioned(
            left: 16,
            right: 16,
            top: _clampTop(
              mediaPadding,
              vm.qrRect!.bottom + 12,
              MediaQuery.of(context).size.height,
            ),
            child: _ProductOverlay(vm: vm),
          ),

        /* Instructions */
        if (vm.overlayProduct == null)
          Positioned(
            bottom: mediaPadding.bottom + 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Scannez le code d\'un article',
                style: AppTextStyles.body.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  double _clampTop(EdgeInsets pad, double desiredTop, double screenH) {
    const cardH = 96.0;
    final maxTop = screenH - pad.bottom - 16 - cardH;
    return desiredTop.clamp(pad.top + 16, maxTop);
  }
}

class _ProductOverlay extends StatelessWidget {
  const _ProductOverlay({required this.vm});
  final AddItemToShelfVM vm;

  @override
  Widget build(BuildContext context) {
    final p = vm.overlayProduct!;
    final already = vm.alreadyOnShelf.contains(p.id) ||
        vm.selected.containsKey(p.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 24,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name ?? 'Article inconnu',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  already ? 'Déjà ajouté' : 'Appuyez pour ajouter',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    color: already ? Colors.orange[600] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              if (!already)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7B8F),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'Ajouter',
                    onPressed: () async {
                      final res = await vm.addProduct(
                        p.id,
                        p.name ?? 'Item',
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            res.added
                                ? 'Ajouté : ${p.name ?? p.id}'
                                : (res.reason ?? 'Non ajouté'),
                          ),
                          backgroundColor: res.added
                              ? Colors.green[600]
                              : Colors.orange[600],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Fermer',
                  onPressed: vm.clearOverlay,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
