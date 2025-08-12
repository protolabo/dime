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

class _ItemBodyState extends State<_ItemBody> with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _animationController.dispose();
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
      backgroundColor: AppColors.background,
      appBar: const HeaderCommercant(),
      bottomNavigationBar: navbar_commercant(
        currentIndex: 0,
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
      body: vm.isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Header avec titre et actions
            SliverToBoxAdapter(
              child: _buildHeader(context, vm, title),
            ),

            // Contenu principal
            SliverPadding(
              padding: AppPadding.h,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppSpacing.lg),
                  _buildEditSection(context, vm),
                  const SizedBox(height: AppSpacing.xl),
                  if ((vm.description ?? '').trim().isNotEmpty)
                    _buildDescriptionSection(vm),
                  if ((vm.description ?? '').trim().isNotEmpty)
                    const SizedBox(height: AppSpacing.xl),
                  _buildShelvesSection(context, vm),
                  const SizedBox(height: AppSpacing.xl),
                  _buildQRSection(context, vm),
                  const SizedBox(height: AppSpacing.xxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ItemCommercantVM vm, String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.searchBg,
            AppColors.searchBg.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Barre d'actions
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.arrow_back_ios,
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Retour',
                  ),
                  const Spacer(),
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    onPressed: () => _showDeleteDialog(context, vm),
                    tooltip: 'Supprimer de ce magasin',
                    isDestructive: true,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Titre avec icône
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.border,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.inventory_2,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.title.copyWith(fontSize: 20),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (vm.price != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${vm.price!.toStringAsFixed(2)} ${vm.currency ?? 'CAD'}',
                              style: AppTextStyles.price.copyWith(fontSize: 16),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDestructive ? AppColors.danger : AppColors.primary,
          size: 22,
        ),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildEditSection(BuildContext context, ItemCommercantVM vm) {
    return _buildCard(
      title: 'Modifier l\'article',
      icon: Icons.edit,
      child: Column(
        children: [
          _buildEditField(
            controller: _nameCtrl,
            label: 'Nom de l\'article',
            icon: Icons.label_outline,
            onSave: () async {
              await vm.updateName(_nameCtrl.text);
              if (!context.mounted) return;
              _showSnackBar(context, vm.errorMessage ?? 'Nom mis à jour avec succès');
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildEditField(
            controller: _priceCtrl,
            label: 'Prix régulier',
            icon: Icons.attach_money,
            suffix: Text('CAD', style: AppTextStyles.muted),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onSave: () async {
              final txt = _priceCtrl.text.replaceAll(',', '.');
              final amt = double.tryParse(txt);
              if (amt == null) {
                _showSnackBar(context, 'Prix invalide', isError: true);
                return;
              }
              await vm.updatePrice(amt, currencyCode: vm.currency ?? 'CAD');
              if (!context.mounted) return;
              _showSnackBar(context, vm.errorMessage ?? 'Prix mis à jour avec succès');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Widget? suffix,
    TextInputType? keyboardType,
    required VoidCallback onSave,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: AppRadius.border,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTextStyles.input,
              decoration: InputDecoration(
                labelText: label,
                suffix: suffix,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              elevation: 0,
            ),
            child: const Text('Sauver', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ItemCommercantVM vm) {
    return _buildCard(
      title: 'Description',
      icon: Icons.description_outlined,
      child: Text(
        vm.description!,
        style: AppTextStyles.body.copyWith(height: 1.5),
      ),
    );
  }

  Widget _buildShelvesSection(BuildContext context, ItemCommercantVM vm) {
    return _buildCard(
      title: 'Étagères (${vm.shelves.length})',
      icon: Icons.shelves,
      child: vm.shelves.isEmpty
          ? _buildEmptyState('Cet article n\'est sur aucune étagère de ce magasin.')
          : Column(
        children: vm.shelves.asMap().entries.map((entry) {
          final index = entry.key;
          final shelf = entry.value;
          final isLast = index == vm.shelves.length - 1;

          return Column(
            children: [
              _buildShelfTile(context, shelf),
              if (!isLast)
                Divider(
                  color: AppColors.border,
                  height: 1,
                  indent: AppSpacing.xl,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShelfTile(BuildContext context, ItemShelfRef shelf) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShelfPageCommercant(
              shelfName: shelf.name,
              shelfId: shelf.shelfId,
            ),
          ),
        );
      },
      borderRadius: AppRadius.border,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.searchBg,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.folder_open,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                shelf.name,
                style: AppTextStyles.itemTitle,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRSection(BuildContext context, ItemCommercantVM vm) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          await vm.downloadItemQrPdf();
          if (!context.mounted) return;
          if (vm.errorMessage != null) {
            _showSnackBar(context, vm.errorMessage!, isError: true);
          } else {
            _showSnackBar(context, 'QR Code téléchargé avec succès');
          }
        },
        icon: const Icon(Icons.qr_code, size: 20),
        label: const Text(
          'Télécharger le QR Code',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.border,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(icon, color: AppColors.accent, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTextStyles.sectionTitle),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: AppTextStyles.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, ItemCommercantVM vm) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.border),
        title: const Text('Retirer l\'article du magasin ?'),
        content: const Text(
          'Cette action supprimera son prix dans ce magasin et le retirera de toutes les étagères de ce magasin. Le produit lui-même ne sera pas supprimé du catalogue global.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      final success = await vm.removeFromCurrentStore();
      if (!context.mounted) return;
      _showSnackBar(
        context,
        success
            ? 'Article retiré de ce magasin.'
            : (vm.errorMessage ?? 'Échec de la suppression de l\'article.'),
        isError: !success,
      );
      if (success) Navigator.of(context).maybePop();
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.border),
      ),
    );
  }
}