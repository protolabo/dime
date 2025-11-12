import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dime_flutter/view/styles.dart';

import 'package:dime_flutter/view/components/header_client.dart';
import 'package:dime_flutter/view/components/nav_bar_client.dart';
import 'package:dime_flutter/vm/client/item_page_vm.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';
import 'package:dime_flutter/view/client/store_page_customer.dart';
import 'package:dime_flutter/view/client/search_page_client.dart';

import '../../auth_viewmodel.dart';

class ItemPageCustomer extends StatelessWidget {
  final int productId;
  final String? locatedStoreName; // optionnel

  const ItemPageCustomer({
    super.key,
    required this.productId,
    this.locatedStoreName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemPageViewModel(productId: productId,auth: context.read<AuthViewModel>()),
      child: Consumer<ItemPageViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.error != null) {
            return Scaffold(body: Center(child: Text(vm.error!)));
          }

          return Scaffold(
            appBar: Header(vm.currentStoreName),
            body: SingleChildScrollView(
              padding: AppPadding.all,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* ---------- Image + Nom + Cœur + Prix minimal ---------- */
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* mini-mock image */
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
                              'picture item',
                              style: TextStyle(fontSize: 10),
                            ),
                            Icon(Icons.photo_camera, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      /* nom + barcode + store où tu l’as scanné */
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vm.productName, style: AppTextStyles.title),
                            const SizedBox(height: 4),
                            Text(
                              vm.barCode.isNotEmpty
                                  ? 'Barcode: ${vm.barCode}'
                                  : 'Barcode non disponible',
                              style: AppTextStyles.body.copyWith(fontSize: 12),
                            ),
                            if (locatedStoreName != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      'Located at: ',
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(4),
                                      onTap: () {
                                        final match = vm.storesWithPrice
                                            .firstWhere(
                                              (e) =>
                                          e['store_name'] ==
                                              locatedStoreName,
                                          orElse: () => {},
                                        );
                                        if (match.isNotEmpty) {
                                          final int storeId =
                                          match['store_id'] as int;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => StorePageCustomer(
                                                storeId: storeId,
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Impossible de trouver ce magasin.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        locatedStoreName!,
                                        style: AppTextStyles.body.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      /* colonne cœur + prix min */
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: vm.isFavorite
                                  ? AppColors.danger
                                  : Colors.grey.shade400,
                              size: 30,
                            ),
                            onPressed: vm.toggleFavorite,
                          ),
                          if (vm.minPrice != null)
                            Text(
                              '${vm.minPrice!.toStringAsFixed(2)}\$',
                              style: AppTextStyles.subtitle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /* ---------- Commerces ---------- */
                  Text(
                    'Commerces with the item',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 8),
                  if (vm.storesForSection.isEmpty)
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
                        itemCount: vm.storesForSection.length,
                        separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Colors.black12),
                        itemBuilder: (_, i) {
                          final s = vm.storesForSection[i];
                          final fav = vm.favoriteStoreIds.contains(
                            s['store_id'] as int,
                          );
                          final priceText =
                              '${(s['price'] as num).toStringAsFixed(2)}\$';

                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.favorite,
                              color: fav ? AppColors.danger : Colors.white,
                            ),

                            /* ─── Nom du commerce cli­quable ─── */
                            title: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: () {
                                final int storeId = s['store_id'] as int;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        StorePageCustomer(storeId: storeId),
                                  ),
                                );
                              },
                              child: Text(
                                s['store_name'] ?? '',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            /* ─── Prix cliquable ─── */
                            trailing: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: () {
                                final int pid = s['product_id'] as int;
                                if (pid != productId) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ItemPageCustomer(
                                        productId: pid,
                                        locatedStoreName:
                                        s['store_name'] as String,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  priceText,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 20),

                  /* ---------- Placeholder pour items similaires ---------- */
                  Text('Similar item', style: AppTextStyles.subtitle),
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

            /* ---------- Bottom nav ---------- */
            bottomNavigationBar: navbar_client(
              currentIndex: 3,
              onTap: (i) {
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
                } else if (i == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchPage()),
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
