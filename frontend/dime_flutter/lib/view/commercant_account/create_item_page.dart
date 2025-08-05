import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dime_flutter/vm/create_item_vm.dart';

import 'package:dime_flutter/view/styles.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final barcodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateItemViewModel(),
      child: Consumer<CreateItemViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppColors.searchBg, // ⬅️ ancien 0xFFFDF1DC
          appBar: AppBar(
            title: Text(
              'Create a new item',
              style: AppTextStyles.subtitle.copyWith(fontSize: 24),
            ),
            backgroundColor: AppColors.searchBg,
            elevation: 0,
            centerTitle: true,
          ),

          body: Padding(
            padding: AppPadding.horizontal.copyWith(top: 16), // ⬅️
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* -------- Image + nom -------- */
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('picture item', style: TextStyle(fontSize: 10)),
                          Icon(Icons.photo_camera, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Name of the item',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: Colors.grey[700],
                          ),
                          filled: true,
                          fillColor: Colors.amber[100],
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /* -------- Barcode -------- */
                TextField(
                  controller: barcodeController,
                  decoration: InputDecoration(
                    hintText: 'Barcode (ex: 123456789)',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: Colors.grey[700],
                    ),
                    filled: true,
                    fillColor: Colors.amber[100],
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                /* -------- Price -------- */
                Text(
                  'Price',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter price (e.g. 9.99)',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: Colors.grey[700],
                    ),
                    filled: true,
                    fillColor: Colors.amber[100],
                    border: const OutlineInputBorder(),
                    suffixText: '\$',
                  ),
                ),
                const SizedBox(height: 24),

                /* -------- Description -------- */
                Text(
                  'Description',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 7,
                  decoration: InputDecoration(
                    hintText: 'Enter description...',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: Colors.grey[700],
                    ),
                    filled: true,
                    fillColor: Colors.amber[100],
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                /* -------- QR / Loader / Error -------- */
                if (vm.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (vm.qrDataUrl != null)
                  Center(
                    child: Image.memory(
                      base64Decode(vm.qrDataUrl!.split(',').last),
                      height: 200,
                    ),
                  )
                else if (vm.errorMessage != null)
                  Text(
                    vm.errorMessage!,
                    style: AppTextStyles.body.copyWith(color: Colors.red),
                  ),

                const Spacer(),

                /* -------- Save button -------- */
                Center(
                  child: SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent, // ⬅️
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        vm.generateQrCode(
                          name: nameController.text,
                          barcode: barcodeController.text,
                          price: priceController.text,
                          description: descriptionController.text,
                        );
                      },
                      child: Text(
                        'Save',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
