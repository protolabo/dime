import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/commercant/create_item_vm.dart';
import 'package:dime_flutter/vm/components/barcode_scanner_vm.dart';

import '../../auth_viewmodel.dart';
import 'create_qr_menu.dart';
import 'myTeam.dart';
import 'scan_page_commercant.dart';
import 'search_page_commercant.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _nameC = TextEditingController();
  final _barCodeC = TextEditingController();
  final _priceC = TextEditingController();
  final _descriptionC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    _barCodeC.dispose();
    _priceC.dispose();
    _descriptionC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CreateItemViewModel(auth: context.read<AuthViewModel>())),
        ChangeNotifierProvider(create: (_) => BarcodeScannerVM()),
      ],
      child: Consumer<CreateItemViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: Colors.white,
          appBar: const HeaderCommercant(),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ajouter un produit',
                        style: AppTextStyles.title.copyWith(fontSize: 22),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /* Image Section */
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
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
                                  'Aucune image',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(
                            vm.selectedImage == null
                                ? Icons.add_photo_alternate
                                : Icons.edit,
                            size: 20,
                          ),
                          label: Text(
                            vm.selectedImage == null
                                ? 'Ajouter une photo'
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
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /* Form Section */
                Text(
                  'Informations du produit',
                  style: AppTextStyles.title.copyWith(fontSize: 18),
                ),

                const SizedBox(height: 16),

                _InputField(label: 'Nom du produit', controller: _nameC),
                const SizedBox(height: 16),

                BarcodeField(
                  controller: _barCodeC,
                  label: 'Code-barres',
                  hint: 'Scannez ou entrez le code',
                  onScan: (barcode) async {
                    _nameC.text = '';
                    _descriptionC.text = '';
                    _priceC.text = '';
                    final off = await vm.lookupBarcode(barcode);
                    if (off != null) {
                      final name = off.name ?? '';
                      final desc = off.description ?? '';
                      if (name.isNotEmpty) _nameC.text = name;
                      if (desc.isNotEmpty) _descriptionC.text = desc;
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Produit trouvé sur Open Food Facts'),
                            backgroundColor: Colors.green[600],
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Produit introuvable sur Open Food Facts'),
                            backgroundColor: Colors.orange[600],
                          ),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 16),

                _InputField(
                  label: 'Prix (\$)',
                  controller: _priceC,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{0,6}(\.\d{0,2})?$'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _InputField(
                  label: 'Description',
                  controller: _descriptionC,
                  maxLines: 3,
                ),

                const SizedBox(height: 32),

                /* Save Button */
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B7B8F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: vm.isSaving
                        ? null
                        : () => vm.saveItem(
                      name: _nameC.text.trim(),
                      barCode: _barCodeC.text.trim(),
                      price: _priceC.text.trim(),
                      description: _descriptionC.text.trim(),
                      context: context,
                    ),
                    child: vm.isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Enregistrer le produit',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
          bottomNavigationBar: navbar_commercant(
            currentIndex: 0,
            onTap: (index) {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateQrMenuPage()),
                );
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageTeamPage()),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanCommercantPage()),
                );
              } else if (index == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchPageCommercant()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

/* ──────────── INPUT FIELD ──────────── */
class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      style: AppTextStyles.body.copyWith(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body.copyWith(
          fontSize: 14,
          color: Colors.grey[600],
        ),
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
    );
  }
}

/* ──────────── BARCODE FIELD ──────────── */
class BarcodeField extends StatefulWidget {
  const BarcodeField({
    required this.controller,
    this.label = 'Barcode',
    this.hint,
    this.onScan,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final Future<void> Function(String barcode)? onScan;

  @override
  State<BarcodeField> createState() => _BarcodeFieldState();
}

class _BarcodeFieldState extends State<BarcodeField> {
  bool _scanning = false;

  Future<void> _openScanner() async {
    if (_scanning) return;
    setState(() => _scanning = true);

    final scannerVm = Provider.of<BarcodeScannerVM>(context, listen: false);
    final result = await scannerVm.scan(context);

    if (result != null && result.isNotEmpty) {
      widget.controller.text = result;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.controller.text.length),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Code scanné'),
            backgroundColor: Colors.green[600],
          ),
        );
      }
      if (widget.onScan != null) {
        await widget.onScan!(result);
      }
    }

    setState(() => _scanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      style: AppTextStyles.body.copyWith(fontSize: 15),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: AppTextStyles.body.copyWith(
          fontSize: 14,
          color: Colors.grey[600],
        ),
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
        suffixIcon: Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Color(0xFF8B7B8F),
            borderRadius: BorderRadius.circular(6),
          ),
          child: IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            tooltip: 'Scanner un code',
            onPressed: _openScanner,
          ),
        ),
      ),
      onSubmitted: (value) async {
        if (value.isNotEmpty && widget.onScan != null) {
          await widget.onScan!(value);
        }
      },
    );
  }
}
