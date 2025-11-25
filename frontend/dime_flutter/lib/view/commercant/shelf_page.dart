import 'dart:typed_data';

import 'package:dime_flutter/view/commercant/myTeam.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  const _ShelfPageBody();

  @override
  State<_ShelfPageBody> createState() => _ShelfPageBodyState();
}

class _ShelfPageBodyState extends State<_ShelfPageBody> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShelfPageVM>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const HeaderCommercant(),
      bottomNavigationBar: navbar_commercant(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQrMenuPage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageTeamPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanCommercantPage()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPageCommercant()));
          }
        },
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
          ? _ErrorView(error: vm.error!)
          : _Content(vm: vm),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Erreur: $error',
            style: AppTextStyles.body.copyWith(color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.vm});

  final ShelfPageVM vm;

  @override
  Widget build(BuildContext context) {
    final name = vm.shelfName ?? vm.initialShelfName;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* Back Button + Title + Delete */
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
                child: Text(
                  name,
                  style: AppTextStyles.title.copyWith(fontSize: 22),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.red[600]),
                  tooltip: 'Supprimer l\'étagère',
                  onPressed: () => _showDeleteDialog(context, vm),
                ),
              ),
            ],
          ),

          /* Image Section */
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.image_outlined, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Photo de l\'étagère',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (vm.selectedImage != null)
                  FutureBuilder<Uint8List>(
                    future: vm.selectedImage!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            snapshot.data!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  )
                else if (vm.imageUrl != null && vm.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      vm.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                    ),
                  )
                else
                  _buildPlaceholder(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          vm.selectedImage == null
                              ? (vm.imageUrl == null || vm.imageUrl!.isEmpty
                              ? Icons.add_photo_alternate
                              : Icons.edit)
                              : Icons.edit,
                          size: 20,
                        ),
                        label: Text(
                          vm.selectedImage == null
                              ? (vm.imageUrl == null || vm.imageUrl!.isEmpty
                              ? 'Ajouter une photo'
                              : 'Changer la photo')
                              : 'Changer la photo',
                          style: AppTextStyles.body.copyWith(fontSize: 15),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            vm.setImage(image);
                          }
                        },
                      ),
                    ),
                    if (vm.selectedImage != null) ...[
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await vm.updateImage();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                vm.error ?? 'Image mise à jour',
                              ),
                              backgroundColor: vm.error != null
                                  ? Colors.red[600]
                                  : Colors.green[600],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B7B8F),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Enregistrer',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),


          /* Section Articles */
          Row(
            children: [
              Text(
                'Articles',
                style: AppTextStyles.title.copyWith(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B7B8F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${vm.items.length}',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8B7B8F),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /* Liste des articles */
          vm.items.isEmpty
              ? Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun article dans cette étagère',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
              : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vm.items.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final item = vm.items[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemCommercantPage(
                          productId: item.productId,
                          productName: item.name,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (item.price != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${item.price!.toStringAsFixed(2)} ${item.currency ?? 'CAD'}',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          /* Bouton Ajouter un article */
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 20,color: Colors.white),
              label: Text(
                'Ajouter un article',
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B7B8F),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                final int? id = vm.shelfId;
                final String? rawName = vm.shelfName;

                if (id == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ID d\'étagère manquant')),
                  );
                  return;
                }

                final String name = rawName ?? vm.initialShelfName;

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddItemToShelfPage(
                      shelfId: id,
                      shelfName: name,
                    ),
                  ),
                );

                if (context.mounted) vm.reload();
              },
            ),
          ),

          const SizedBox(height: 16),

          /* Bouton Télécharger QR Code */
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.qr_code, size: 20, color: Colors.white),
              label: Text(
                'Télécharger le QR Code',
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF2D2D2D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await vm.downloadQrPdf();
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('QR Code téléchargé'),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, ShelfPageVM vm) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer cette étagère ?'),
        titleTextStyle: AppTextStyles.title.copyWith(fontSize: 18),
        content: const Text(
          'Cette action supprimera définitivement l\'étagère et retirera tous les articles associés. Cette action est irréversible.',
        ),
        contentTextStyle: AppTextStyles.body.copyWith(fontSize: 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Annuler',
              style: AppTextStyles.body.copyWith(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      // Appeler la méthode de suppression du VM (à implémenter)
      // await vm.deleteShelf();
      Navigator.of(context).pop(true);
    }
  }
  Widget _buildPlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune image',
              style: AppTextStyles.body.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
