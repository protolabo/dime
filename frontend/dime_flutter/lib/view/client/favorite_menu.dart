import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/view/components/header_client.dart';
import 'package:dime_flutter/view/components/nav_bar_client.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';
import 'package:dime_flutter/view/fenetre/fav_item_fenetre.dart';
import 'package:dime_flutter/view/fenetre/fav_commerce_fenetre.dart';
import 'package:dime_flutter/view/client/item_page_customer.dart';
import 'package:dime_flutter/view/client/store_page_customer.dart';
import 'package:dime_flutter/view/client/search_page_client.dart';

import 'package:dime_flutter/vm/client/favorite_menu_vm.dart';

class FavoriteMenuPage extends StatefulWidget {
  const FavoriteMenuPage({super.key});

  @override
  State<FavoriteMenuPage> createState() => _FavoriteMenuPageState();
}

class _FavoriteMenuPageState extends State<FavoriteMenuPage> {
  late final FavoriteMenuVM _vm;

  @override
  void initState() {
    super.initState();
    _vm = FavoriteMenuVM()..init();
  }

  @override
  void dispose() {
    _vm.persistDeletions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<FavoriteMenuVM>(
        builder: (context, vm, _) {
          /* ----------- états de chargement/erreur ----------- */
          if (vm.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.error != null) {
            return Scaffold(
              appBar: const Header(null),
              body: Center(
                child: Text('Erreur : ${vm.error}', style: AppTextStyles.body),
              ),
            );
          }

          /* --------------------- UI --------------------- */
          return Scaffold(
            appBar: const Header(null),
            body: Padding(
              padding: AppPadding.all,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* ----------- mes produits favoris ----------- */
                    Text(
                      'My favorite items',
                      style: AppTextStyles.subtitle.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (vm.favoriteProducts.isEmpty)
                      SizedBox(
                        height: 160,
                        child: Center(
                          child: Text(
                            'Vous n\'avez aucun favori.',
                            style: AppTextStyles.body,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: vm.favoriteProducts.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final product = vm.favoriteProducts[i];
                            return InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ItemPageCustomer(productId: product.id),
                                ),
                              ),
                              child: FavItemFenetre(
                                name: product.name,
                                isFavorite:
                                vm.favoriteProductStates[product.id] ?? true,
                                onFavoriteChanged: (fav) => vm
                                    .toggleProduct(product.id, fav), // 🔄
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 24),

                    /* ----------- mes commerces favoris ----------- */
                    Text(
                      'My favorite commerces',
                      style: AppTextStyles.subtitle.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (vm.favoriteStores.isEmpty)
                      SizedBox(
                        height: 160,
                        child: Center(
                          child: Text(
                            'Vous n\'avez aucun commerce favori.',
                            style: AppTextStyles.body,
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: vm.favoriteStores.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final store = vm.favoriteStores[i];
                            return InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      StorePageCustomer(storeId: store.id),
                                ),
                              ),
                              child: FavCommerceFenetre(
                                name: store.name,
                                isFavorite:
                                vm.favoriteStoreStates[store.id] ?? true,
                                onFavoriteChanged: (fav) =>
                                    vm.toggleStore(store.id, fav), // 🔄
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 24),
                    // … (autres sections à venir) …
                  ],
                ),
              ),
            ),

            /* ----------- barre de navigation ----------- */
            bottomNavigationBar: navbar_client(
              currentIndex: 0,
              onTap: (i) async {
                await _vm.persistDeletions();
                if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanClientPage()),
                  );
                } else if (i == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
                  );
                }
                // i == 2 : historique
              },
            ),
          );
        },
      ),
    );
  }
}
