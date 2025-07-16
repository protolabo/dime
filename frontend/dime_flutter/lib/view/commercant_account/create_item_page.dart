import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dime_flutter/vm/create_item_vm.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  @override
  State<CreateItemPage> createState() => _CreateItemPageState();
}

class _CreateItemPageState extends State<CreateItemPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final barcodeController =
      TextEditingController(); // Tu peux gérer ça avec le scan plus tard

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateItemViewModel(),
      child: Consumer<CreateItemViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFFDF1DC),
            appBar: AppBar(
              title: const Text(
                "Create a new item",
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
              backgroundColor: const Color(0xFFFDF1DC),
              elevation: 0,
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image picker mockup
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
                            Text(
                              "picture item",
                              style: TextStyle(fontSize: 10),
                            ),
                            Icon(Icons.photo_camera, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Name of the item",
                            hintStyle: TextStyle(color: Colors.grey[700]),
                            filled: true,
                            fillColor: Colors.amber[100],
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: barcodeController,
                    decoration: InputDecoration(
                      hintText: "Barcode (ex: 123456789)",
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.amber[100],
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Price", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter price (e.g. 9.99)",
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.amber[100],
                      border: const OutlineInputBorder(),
                      suffixText: "\$",
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text("Description", style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    maxLines: 7,
                    decoration: InputDecoration(
                      hintText: "Enter description...",
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      filled: true,
                      fillColor: Colors.amber[100],
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                      style: const TextStyle(color: Colors.red),
                    ),

                  const Spacer(),

                  Center(
                    child: SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
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
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
