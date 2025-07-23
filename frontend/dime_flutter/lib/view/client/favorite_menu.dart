import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dime_flutter/view/components/header.dart';
import 'package:dime_flutter/view/components/navbar_scanner.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';
import 'package:dime_flutter/view/fenetre/fav-item-fenetre.dart';
import 'package:dime_flutter/view/fenetre/fav_commerce_fenetre.dart';
import 'package:dime_flutter/vm/current_connected_client_vm.dart';
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
    final supabase = Supabase.instance.client;

    // Produits
    for (final e in favoriteProductStates.entries) {
      if (!e.value) {
        await supabase
            .from('favorite_product')
            .delete()
            .eq('actor_id', _client!.actorId)
            .eq('product_id', e.key);
      }
    }

    // Commerces
    for (final e in favoriteStoreStates.entries) {
      if (!e.value) {
        await supabase
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: const Header(null),
        body: Center(child: Text('Erreur : $_error')),
      );
    }

    return Scaffold(
      appBar: const Header(null),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- My favorite items ---
              const Text(
                'My favorite items',
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              if (favoriteProducts.isEmpty)
                SizedBox(
                  height: 160,
                  child: Center(child: Text('Vous n\'avez aucun favori...')),
                )
              else
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: favoriteProducts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) => FavItemFenetre(
                      name: favoriteProducts[i].name,
                      isFavorite:
                          favoriteProductStates[favoriteProducts[i].id] ?? true,
                      onFavoriteChanged: (fav) {
                        setState(
                          () => favoriteProductStates[favoriteProducts[i].id] =
                              fav,
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // --- My favorite commerces ---
              const Text(
                'My favorite commerces',
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              if (favoriteStores.isEmpty)
                SizedBox(
                  height: 160,
                  child: Center(
                    child: Text('Vous n\'avez aucun commerce favori...'),
                  ),
                )
              else
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: favoriteStores.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) => FavCommerceFenetre(
                      name: favoriteStores[i].name,
                      isFavorite:
                          favoriteStoreStates[favoriteStores[i].id] ?? true,
                      onFavoriteChanged: (fav) {
                        setState(
                          () => favoriteStoreStates[favoriteStores[i].id] = fav,
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              //  ... Recommended items & commerces ...
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar_Scanner(
        currentIndex: 0,
        onTap: (i) async {
          await _persistDeletions();
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanClientPage()),
            );
          }
        },
      ),
    );
  }
}
