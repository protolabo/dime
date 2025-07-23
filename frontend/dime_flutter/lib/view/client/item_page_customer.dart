import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/components/header.dart';
import 'package:dime_flutter/view/components/navbar_scanner.dart';
import 'package:dime_flutter/vm/item_page_vm.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';

class ItemPageCustomer extends StatelessWidget {
  final int productId;
  const ItemPageCustomer({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemPageViewModel(productId: productId),
      child: Consumer<ItemPageViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.error != null) {
            return Scaffold(
              appBar: const Header(null),
              body: Center(child: Text('Erreur : ${vm.error}')),
            );
          }

          final prod = vm.product!;

          return Scaffold(
            backgroundColor: const Color(0xFFFDF1DC),
            appBar: const Header(null),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Image + Nom + Cœur ----------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encadré photo
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                prod['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: vm.isFavorite
                                    ? Colors.red
                                    : Colors.grey.shade400,
                                size: 30,
                              ),
                              onPressed: vm.toggleFavorite,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ---------- Bar code ----------
                  Text(
                    prod['bar_code'] != null &&
                        prod['bar_code'].toString().trim().isNotEmpty
                        ? 'Bar code: ${prod['bar_code']}'
                        : 'Bar code: — (non disponible)',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 20),

                  // ---------- Commerces ----------
                  const Text(
                    'Commerces with the item',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (vm.storesWithPrice.isEmpty)
                    const Text('Aucun commerce trouvé')
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: vm.storesWithPrice.length,
                        separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Colors.black12),
                        itemBuilder: (_, i) {
                          final s = vm.storesWithPrice[i];
                          final fav = vm.favoriteStoreIds.contains(
                            s['store_id'] as int,
                          );
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.favorite,
                              color: fav ? Colors.red : Colors.white,
                            ),
                            title: Text(s['store_name'] ?? ''),
                            trailing: Text('\$${s['price']}'),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ---------- Similar item ----------
                  const Text(
                    'Similar item',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Placeholder for similar items'),
                  ),
                ],
              ),
            ),

            // ---------- Bottom nav ----------
            bottomNavigationBar: NavBar_Scanner(
              currentIndex: 3,
              onTap: (i) async {
                if (i == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoriteMenuPage()),
                  );
                } else if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanClientPage()),
                  );
                }
                // i == 2: historic, i == 3: stay on search
              },
            ),
          );
        },
      ),
    );
  }
}
