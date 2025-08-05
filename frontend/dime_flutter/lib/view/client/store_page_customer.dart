import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dime_flutter/view/styles.dart';

import 'package:dime_flutter/vm/store_page_vm.dart';
import 'package:dime_flutter/view/components/header.dart';
import 'package:dime_flutter/view/components/navbar_scanner.dart';
import 'package:dime_flutter/view/fenetre/fav_item_fenetre.dart';
import 'package:dime_flutter/view/client/item_page_customer.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';
import 'package:dime_flutter/view/client/search_page.dart';


const _bg = AppColors.searchBg;

class StorePageCustomer extends StatelessWidget {
  const StorePageCustomer({super.key, required this.storeId});
  final int storeId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StorePageVM()..load(storeId), // ← utilise l’utilisateur courant
      child: Consumer<StorePageVM>(
        builder: (ctx, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (vm.error != null) {
            return Scaffold(
              appBar: const Header(null),
              body: Center(child: Text(vm.error!)),
            );
          }



          return Scaffold(
            backgroundColor: _bg,
            appBar: const Header(null),
            bottomNavigationBar: NavBar_Scanner(
              currentIndex: 3,
              onTap: (i) {
                if (i == 0) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const FavoriteMenuPage()));
                } else if (i == 1) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ScanClientPage()));
                } else if (i == 3) {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const SearchPage()));
                }
              },
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: AppPadding.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.storefront, size: 32),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vm.storeName ?? 'Unknown store',
                            style: AppTextStyles.title.copyWith(fontSize: 32),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          vm.isStoreFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: vm.isStoreFavorite ? Colors.red : Colors.grey,
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.address ?? 'Adresse non disponible',
                      style: AppTextStyles.body.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    /* ---- recommandations ---- */
                    Text('Items from the store you may like:',
                        style: AppTextStyles.subtitle),
                    const SizedBox(height: 12),

                    if (vm.recos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text('Aucune recommandation pour le moment.'),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vm.recos.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                        ),
                        itemBuilder: (_, i) {
                          final r = vm.recos[i];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ItemPageCustomer(productId: r['id'])),
                            ),
                            child: FavItemFenetre(
                              name: r['title'],
                              isFavorite: r['isFav'] as bool,
                              onFavoriteChanged: (_) {},
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
