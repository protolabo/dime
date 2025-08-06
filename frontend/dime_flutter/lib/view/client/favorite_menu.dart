import 'package:flutter/material.dart';
import 'package:dime_flutter/view/styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:dime_flutter/view/components/header_client.dart';
import 'package:dime_flutter/view/components/nav_bar_client.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';
import 'package:dime_flutter/view/fenetre/fav_item_fenetre.dart';
import 'package:dime_flutter/view/fenetre/fav_commerce_fenetre.dart';
import 'package:dime_flutter/view/client/item_page_customer.dart';
import 'package:dime_flutter/view/client/store_page_customer.dart';
import 'package:dime_flutter/vm/current_connected_account_vm.dart';
import 'package:dime_flutter/view/client/search_page.dart';
import 'package:dime_flutter/vm/favorite_product_vm.dart'
    show Product, FavoriteProductService;
import 'package:dime_flutter/vm/favorite_store_vm.dart'
    show Store, FavoriteStoreService;

class FavoriteMenuPage extends StatefulWidget {
  const FavoriteMenuPage({super.key});
  @override
  State<FavoriteMenuPage> createState() => _FavoriteMenuPageState();
}

class _FavoriteMenuPageState extends State<FavoriteMenuPage> {
  Client? _client;
  List<Product> favoriteProducts = [];
  List<Store> favoriteStores = [];

  Map<int, bool> favoriteProductStates = {};
  Map<int, bool> favoriteStoreStates = {};

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final actor = await CurrentActorService.getCurrentActor();
      final products = await FavoriteProductService.fetchFavorites(
        actor.actorId,
      );
      final stores = await FavoriteStoreService.fetchFavorites(actor.actorId);

      setState(() {
        _client = actor;
        favoriteProducts = products;
        favoriteStores = stores;
        favoriteProductStates = {for (var p in products) p.id: true};
        favoriteStoreStates = {for (var s in stores) s.id: true};
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _persistDeletions() async {
    if (_client == null) return;
    final sb = Supabase.instance.client;

    // produits
    for (final e in favoriteProductStates.entries) {
      if (!e.value) {
        await sb
            .from('favorite_product')
            .delete()
            .eq('actor_id', _client!.actorId)
            .eq('product_id', e.key);
      }
    }
    // commerces
    for (final e in favoriteStoreStates.entries) {
      if (!e.value) {
        await sb
            .from('favorite_store')
            .delete()
            .eq('actor_id', _client!.actorId)
            .eq('store_id', e.key);
      }
    }
  }

  @override
  void dispose() {
    _persistDeletions();
    super.dispose();
  }

  /*────────────────────────── UI ──────────────────────────*/
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: const Header(null),
        body: Center(
          child: Text('Erreur : $_error', style: AppTextStyles.body),
        ),
      );
    }

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

              if (favoriteProducts.isEmpty)
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
                    itemCount: favoriteProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final product = favoriteProducts[i];
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
                          isFavorite: favoriteProductStates[product.id] ?? true,
                          onFavoriteChanged: (fav) => setState(
                            () => favoriteProductStates[product.id] = fav,
                          ),
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

              if (favoriteStores.isEmpty)
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
                    itemCount: favoriteStores.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final store = favoriteStores[i];
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
                          isFavorite: favoriteStoreStates[store.id] ?? true,
                          onFavoriteChanged: (fav) => setState(
                            () => favoriteStoreStates[store.id] = fav,
                          ),
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

      bottomNavigationBar: navbar_client(
        currentIndex: 0,
        onTap: (i) async {
          await _persistDeletions();
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
          // i==2: historique
        },
      ),
    );
  }
}
