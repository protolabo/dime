import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/commercant/create_shelf_vm.dart';

class CreateShelfPage extends StatefulWidget {
  const CreateShelfPage({super.key});

  @override
  State<CreateShelfPage> createState() => _CreateShelfPageState();
}

class _CreateShelfPageState extends State<CreateShelfPage> {
  final _nameC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateShelfViewModel(),
      child: Consumer<CreateShelfViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppColors.searchBg,
            appBar: const HeaderCommercant(),

            body: SingleChildScrollView(
              padding: AppPadding.horizontal.copyWith(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create a new shelf', style: AppTextStyles.title),
                  const SizedBox(height: 24),

                  TextField(
                    controller: _nameC,
                    decoration: const InputDecoration(
                      labelText: 'Name of the shelf',
                      border: OutlineInputBorder(borderRadius: AppRadius.border),
                    ),
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
                          : () => vm.saveShelf(
                        shelfName: _nameC.text.trim(),
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

            bottomNavigationBar: navbar_commercant(
              currentIndex: 0, // My Commerce
              onTap: (i) {
                // tu brancheras plus tard
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tab $i')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
