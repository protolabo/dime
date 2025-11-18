import 'package:dime_flutter/view/commercant/myTeam.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/components/header_commercant.dart';
import 'package:dime_flutter/view/components/nav_bar_commercant.dart';
import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/vm/commercant/create_qr_menu_vm.dart';

import 'scan_page_commercant.dart';
import 'search_page_commercant.dart';

class CreateQrMenuPage extends StatelessWidget {
  const CreateQrMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateQrMenuViewModel(),
      child: Consumer<CreateQrMenuViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: const HeaderCommercant(),
            body: Padding(
              padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Encadré avec le nom du commerce
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.card,
                      border: AppBorders.card,
                      boxShadow: AppShadows.card,
                    ),
                    child: Text(
                      vm.isLoading ? '...' : (vm.storeName ?? '—'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                    ),
                  ),

                  const SizedBox(height: 80),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: AppButtonStyles.primary, // ✅ vert Dime
                          onPressed: () => vm.goToCreateItem(context),
                          child: const Text(
                            'Create Item',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: ElevatedButton(
                          style: AppButtonStyles.primary, // ✅ vert Dime
                          onPressed: () => vm.goToCreateShelf(context),
                          child: const Text(
                            'Create shelf',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            bottomNavigationBar: navbar_commercant(
              currentIndex: 0,
              onTap: (i) {
                if (i == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanCommercantPage()),
                  );

                }
                else if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageTeamPage()),
                  );
                }else if (i == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPageCommercant()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
