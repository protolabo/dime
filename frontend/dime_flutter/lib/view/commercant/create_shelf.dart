import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/commercant/create_shelf_vm.dart';

import '../../auth_viewmodel.dart';
import 'create_qr_menu.dart';
import 'myTeam.dart';
import 'scan_page_commercant.dart';
import 'search_page_commercant.dart';

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
      create: (_) => CreateShelfViewModel(auth: context.read<AuthViewModel>()),
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        tooltip: 'Go Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
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
                      style: AppButtonStyles.primary, // ✅ vert centralisé
                      onPressed: vm.isSaving
                          ? null
                          : () => vm.saveShelf(
                        shelfName: _nameC.text.trim(),
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
                }
                else if (index == 1) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageTeamPage()));
                }else if (index == 2) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanCommercantPage()));
                } else if (index == 4) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPageCommercant()));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
