import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dime_flutter/view/styles.dart';

import 'package:dime_flutter/vm/client/search_vm.dart';
import 'package:dime_flutter/view/components/header_client.dart';
import 'package:dime_flutter/view/components/nav_bar_client.dart';
import 'package:dime_flutter/view/client/item_page_customer.dart';
import 'package:dime_flutter/view/client/store_page_customer.dart';
import 'package:dime_flutter/view/fenetre/fav_item_fenetre.dart';
import 'package:dime_flutter/view/fenetre/fav_commerce_fenetre.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _c;
  Timer? _deb;
  @override
  void initState() {
    super.initState();
    _c = TextEditingController();
  }

  @override
  void dispose() {
    _deb?.cancel();
    _c.dispose();
    super.dispose();
  }

  void _onChanged(BuildContext ctx, String v) {
    _deb?.cancel();
    _deb = Timer(
      const Duration(milliseconds: 300),
      () => ctx.read<SearchViewModel>().query(v),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Consumer<SearchViewModel>(
        builder: (ctx, vm, _) => Scaffold(
          backgroundColor: AppColors.searchBg,
          appBar: const Header(null),
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
              }
            },
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* -------- BARRE DE RECHERCHE -------- */
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _c,
                      onChanged: (v) => _onChanged(ctx, v),
                      style: AppTextStyles.body.copyWith(fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'search products or stores',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: _c.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _c.clear();
                                  ctx.read<SearchViewModel>().query('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                /* -------- RÉSULTATS / RECO -------- */
                Expanded(
                  child: _c.text.isEmpty
                      ? _YouMightLike(recos: vm.recos)
                      : _SearchResults(vm: vm),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*──────────────────────────────────────────*/
class _YouMightLike extends StatelessWidget {
  const _YouMightLike({required this.recos});
  final List<Map<String, dynamic>> recos;

  @override
  Widget build(BuildContext context) {
    if (recos.isEmpty) {
      return Center(
        child: Text(
          'Aucune recommandation pour le moment.',
          style: AppTextStyles.body.copyWith(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You might like', style: AppTextStyles.title),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
              ),
              itemCount: recos.length,
              itemBuilder: (_, i) {
                final r = recos[i];
                final Widget tile = r['type'] == 'product'
                    ? FavItemFenetre(
                        name: r['title'],
                        isFavorite: r['isFav'] ?? false,
                  onFavoriteChanged: (bool fav) =>
                         context.read<SearchViewModel>().toggleFavoriteProduct(r['id'], fav),
                      )
                    : FavCommerceFenetre(
                        name: r['title'],
                        isFavorite: r['isFav'] ?? false,
                  onFavoriteChanged: (bool fav) => context.read<SearchViewModel>().toggleFavoriteStore(r['id'], fav),
                      );

                return GestureDetector(
                  onTap: () {
                    if (r['type'] == 'product') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemPageCustomer(productId: r['id']),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StorePageCustomer(storeId: r['id']),
                        ),
                      );
                    }
                  },
                  child: tile,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/*──────────────────────────────────────────*/
class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.vm});
  final SearchViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.results.isEmpty) {
      return Center(
        child: Text(
          'No result ',
          style: AppTextStyles.body.copyWith(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: vm.results.length,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final it = vm.results[i];
        final isProd = it['type'] == 'product';

        return ListTile(
          leading: Icon(isProd ? Icons.shopping_bag : Icons.store),
          title: Text(
            it['title'],
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            it['subtitle'],
            style: AppTextStyles.body.copyWith(color: Colors.black54),
          ),
          onTap: () {
            if (isProd) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => ItemPageCustomer(productId: it['id']),
                ),
              );
            } else {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => StorePageCustomer(storeId: it['id']),
                ),
              );
            }
          },
        );
      },
    );
  }
}
