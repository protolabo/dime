/*  lib/view/client/store_page_customer.dart  */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/vm/store_page_vm.dart';
import 'package:dime_flutter/view/components/header.dart';
import 'package:dime_flutter/view/components/navbar_scanner.dart';
import 'package:dime_flutter/view/fenetre/fav-item-fenetre.dart';
import 'package:dime_flutter/view/client/item_page_customer.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';

const _bg = Color(0xFFFDF1DC);

class StorePageCustomer extends StatelessWidget {
  const StorePageCustomer({super.key, required this.storeId});
  final int storeId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StorePageVM()..load(storeId),
      child: Consumer<StorePageVM>(
        builder: (ctx, vm, _) => Scaffold(
          backgroundColor: _bg,
          appBar: const Header(null),
          bottomNavigationBar: NavBar_Scanner(
            currentIndex: 3, // onglet Search (celui d’où on arrive)
            onTap: (i) {
              if (i == 0) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FavoriteMenuPage()));
              } else if (i == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ScanClientPage()));
              } else if (i == 3) {
                Navigator.pop(context); // revenir à Search
              }
            },
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* ------ Infos magasin (inchangées) ------ */
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.storefront, size: 32),
                      SizedBox(width: 8),
                      Text('Épicerie John',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Icons.favorite, color: Colors.red, size: 32),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Adress: 123 Rue Principale',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),

                  /* ------ Recommandations ------ */
                  const Text('Items from the store you may like:',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600)),
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
                                  ItemPageCustomer(productId: r['id']),
                            ),
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
                  /* -- Ajoute ici tes autres sections si besoin -- */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
