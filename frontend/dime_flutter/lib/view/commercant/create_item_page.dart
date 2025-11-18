import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          backgroundColor: AppColors.searchBg,
          appBar: const HeaderCommercant(),
          body: SingleChildScrollView(
            padding: AppPadding.horizontal.copyWith(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Go Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
                Text('Add a new product', style: AppTextStyles.title),
                const SizedBox(height: 24),

                _InputField(label: 'Name', controller: _nameC),
                const SizedBox(height: 16),

                BarcodeField(
                  controller: _barCodeC,
                  label: 'Barcode',
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
                          const SnackBar(content: Text('Produit trouvé sur Open Food Facts')),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Produit introuvable sur Open Food Facts')),
                        );
                      }
                    }
                  }, // nouveau callback
                ),
                const SizedBox(height: 10),

                _InputField(
                  label: 'Price',
                  controller: _priceC,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: false,
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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: AppButtonStyles.primary,
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
                        : Text('Save', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: navbar_commercant(
            currentIndex: 0,
            onTap: (index) {
              if (index == 0) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQrMenuPage()));
              }else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageTeamPage()));
              }
              else if (index == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanCommercantPage()));
              } else if (index == 4) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPageCommercant()));
              }
            },
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
    super.key,
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
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderRadius: AppRadius.border),
      ).copyWith(labelText: label),
    );
  }
}

class BarcodeField extends StatefulWidget {
  const BarcodeField({
    required this.controller,
    this.label = 'Barcode',
    this.hint,
    this.onScan, // ajout
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final Future<void> Function(String barcode)? onScan; // ajout

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
          const SnackBar(content: Text('Code scanné')),
        );
      }
      // Déclenche le pré-remplissage OFF
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
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        suffixIcon: IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'Scanner un code',
          onPressed: _openScanner,
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
