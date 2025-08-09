import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/commercant/create_item_vm.dart';

/* ────────────────────────────────────────────────────────────────
   Page permettant au commerçant d’ajouter un nouvel item
   ──────────────────────────────────────────────────────────────── */
class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final _nameC        = TextEditingController();
  final _barCodeC     = TextEditingController();
  final _priceC       = TextEditingController();
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
    return ChangeNotifierProvider(
      create: (_) => CreateItemViewModel(),
      child: Consumer<CreateItemViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppColors.searchBg,
          appBar: const HeaderCommercant(),

          body: SingleChildScrollView(
            padding: AppPadding.horizontal.copyWith(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add a new product', style: AppTextStyles.title),
                const SizedBox(height: 24),

                _InputField(label: 'Name', controller: _nameC),
                const SizedBox(height: 16),

                _InputField(label: 'Barcode', controller: _barCodeC),
                const SizedBox(height: 16),

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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                        ? const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)
                        : Text('Save', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),

          // ⬇️ Ajout: barre de navigation commerçant (My Team sélectionné)
          bottomNavigationBar: navbar_commercant(
            currentIndex: 0,
            onTap: (i) {
              // Pour l’instant: simple feedback pour valider que ça marche
              // (tu brancheras la vraie navigation plus tard)
              debugPrint('Commercant nav tapped: index=$i');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tapped tab index $i'),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/* Widget réutilisable pour les TextField */
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
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderRadius: AppRadius.border),
      ).copyWith(labelText: label),
    );
  }
}
