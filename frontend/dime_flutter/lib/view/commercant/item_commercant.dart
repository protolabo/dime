import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/view/commercant/shelf_page.dart';
import 'package:dime_flutter/vm/commercant/item_commercant_vm.dart';

import '../../auth_viewmodel.dart';
import 'create_qr_menu.dart';
import 'myTeam.dart';
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
        auth: context.read<AuthViewModel>(),
      )..init(),
      child: const _ItemBody(),
    );
  }
}

class _ItemBody extends StatefulWidget {
  const _ItemBody();

  @override
  State<_ItemBody> createState() => _ItemBodyState();
}

class _ItemBodyState extends State<_ItemBody> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _isEditingName = false;
  bool _isEditingPrice = false;
  bool _isEditingDescription = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemCommercantVM>();
    final String title = (vm.productName ?? vm.initialProductName);

    // Sync des champs
    if (_nameCtrl.text.isEmpty && (vm.productName ?? '').isNotEmpty) {
      _nameCtrl.text = vm.productName!;
    }
    if (_priceCtrl.text.isEmpty && vm.price != null) {
      _priceCtrl.text = vm.price!.toStringAsFixed(2);
    }
    if (_descriptionCtrl.text.isEmpty && (vm.description ?? '').isNotEmpty) {
      _descriptionCtrl.text = vm.description!;
    }

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
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.title.copyWith(fontSize: 22),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: Colors.red[700]),
                    onPressed: () => _showDeleteDialog(context, vm),
                    tooltip: 'Remover Item from Store',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

/* Image Section */
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
                        'Product Image',
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
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: AppTextStyles.body.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
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
                              'No image',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                ? 'Add a photo'
                                : 'Change the photo')
                                : 'Change the photo',
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
                            _showSnackBar(
                              context,
                              vm.errorMessage ?? 'Image Updated',
                              isError: vm.errorMessage != null,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8B7B8F),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Save',
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

            /* Informations du produit */
            Text(
              'Product Details',
              style: AppTextStyles.title.copyWith(fontSize: 18),
            ),

            const SizedBox(height: 16),

            /* Nom du produit éditable */
            _buildEditableField(
              label: 'Product Name',
              controller: _nameCtrl,
              isEditing: _isEditingName,
              icon: Icons.label_outline,
              onEdit: () => setState(() => _isEditingName = true),
              onCancel: () {
                setState(() => _isEditingName = false);
                _nameCtrl.text = vm.productName ?? '';
              },
              onSave: () async {
                await vm.updateName(_nameCtrl.text);
                setState(() => _isEditingName = false);
                if (!context.mounted) return;
                _showSnackBar(context, vm.errorMessage ?? 'Name Updated');
              },
            ),

            const SizedBox(height: 16),

            /* Prix éditable */
            _buildEditableField(
              label: 'Regular Price (\$)',
              controller: _priceCtrl,
              isEditing: _isEditingPrice,
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,6}(\.\d{0,2})?$')),
              ],
              onEdit: () => setState(() => _isEditingPrice = true),
              onCancel: () {
                setState(() => _isEditingPrice = false);
                _priceCtrl.text = vm.price?.toStringAsFixed(2) ?? '';
              },
              onSave: () async {
                final amt = double.tryParse(_priceCtrl.text);
                if (amt == null) {
                  _showSnackBar(context, 'Invalid Price', isError: true);
                  return;
                }
                await vm.updatePrice(amt, currencyCode: vm.currency ?? 'CAD');
                setState(() => _isEditingPrice = false);
                if (!context.mounted) return;
                _showSnackBar(context, vm.errorMessage ?? 'Price Updated');
              },
            ),

            const SizedBox(height: 16),

            /* Description éditable */
            _buildEditableField(
              label: 'Description',
              controller: _descriptionCtrl,
              isEditing: _isEditingDescription,
              icon: Icons.description_outlined,
              maxLines: 3,
              onEdit: () => setState(() => _isEditingDescription = true),
              onCancel: () {
                setState(() => _isEditingDescription = false);
                _descriptionCtrl.text = vm.description ?? '';
              },
              onSave: () async {
                await vm.updateDescription(_descriptionCtrl.text);
                setState(() => _isEditingDescription = false);
                if (!context.mounted) return;
              },
            ),

            const SizedBox(height: 24),

            /* Étagères */
            Text(
              'Shelf (${vm.shelves.length})',
              style: AppTextStyles.title.copyWith(fontSize: 18),
            ),

            const SizedBox(height: 16),

            vm.shelves.isEmpty
                ? Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No shelves contain this item.',
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
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.shelves.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final shelf = vm.shelves[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B7B8F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.folder_open,
                        color: Color(0xFF8B7B8F),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      shelf.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
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
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            /* Télécharger QR Code */
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code, size: 20,color: Colors.white),
                label: Text(
                  'Download QR Code',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8B7B8F),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await vm.downloadItemQrPdf();
                  if (!context.mounted) return;
                  if (vm.errorMessage != null) {
                    _showSnackBar(context, vm.errorMessage!, isError: true);
                  } else {
                    _showSnackBar(context, 'QR Code Added with success');
                  }
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required IconData icon,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEditing ? Color(0xFF8B7B8F) : Colors.grey[300]!,
          width: isEditing ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (!isEditing)
                InkWell(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xFF8B7B8F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 16,
                      color: Color(0xFF8B7B8F),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isEditing) ...[
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              autofocus: true,
              style: AppTextStyles.body.copyWith(fontSize: 15),
              decoration: InputDecoration(
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
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B7B8F),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else
            Text(
              controller.text.isEmpty ? 'Not specified' : controller.text,
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                color: controller.text.isEmpty ? Colors.grey[500] : null,
              ),
              maxLines: maxLines,
            ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, ItemCommercantVM vm) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Product(s) from store ?'),
        titleTextStyle: AppTextStyles.title.copyWith(fontSize: 18),
        content: const Text(
          'This action will remove its price from this store and take it off all shelves in this store. The product itself will not be removed from the global catalog.',
        ),
        contentTextStyle: AppTextStyles.body.copyWith(fontSize: 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
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
            ? 'Product Removed from store.'
            : (vm.errorMessage ?? 'Error deleting the product.'),
        isError: !success,
      );
      if (success) {
        if (!context.mounted) return;
        Navigator.of(context).pop(true);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
