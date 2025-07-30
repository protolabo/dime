import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/vm/search_vm.dart';
import 'package:dime_flutter/view/components/header.dart';
import 'package:dime_flutter/view/components/navbar_scanner.dart';
import 'package:dime_flutter/view/client/item_page_customer.dart';
import 'package:dime_flutter/view/client/store_page_customer.dart';
import 'package:dime_flutter/view/fenetre/fav-item-fenetre.dart';
import 'package:dime_flutter/view/fenetre/fav_commerce_fenetre.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';

const _bg   = Color(0xFFFDF1DC);
const _grey = Color(0xFFB5B5B5);

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _c;
  Timer? _deb;
  @override void initState() { super.initState(); _c = TextEditingController(); }
  @override void dispose()  { _deb?.cancel(); _c.dispose(); super.dispose(); }

  void _onChanged(BuildContext ctx, String v) {
    _deb?.cancel();
    _deb = Timer(const Duration(milliseconds: 300),
            () => ctx.read<SearchViewModel>().query(v));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Consumer<SearchViewModel>(
        builder: (ctx, vm, _) => Scaffold(
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
                      horizontal: 24, vertical: 16),
                  child: Container(
                    decoration: BoxDecoration(
                        color: _grey, borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      controller: _c,
                      onChanged: (v) => _onChanged(ctx, v),
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'search products or stores',
                        hintStyle: const TextStyle(
                            color: Colors.white70, fontSize: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        suffixIcon: _c.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white),
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
      return const Center(
        child: Text('Aucune recommandation pour le moment.',
            style: TextStyle(fontSize: 16, color: Colors.black54)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('You might like',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 24, crossAxisSpacing: 24),
              itemCount: recos.length,
              itemBuilder: (_, i) {
                final r = recos[i];
                final Widget tile = r['type'] == 'product'
                    ? FavItemFenetre(
                  name            : r['title'],
                  isFavorite      : r['isFav'] ?? false,  //coeur rouge si favori
                  onFavoriteChanged: (_) {},
                )
                    : FavCommerceFenetre(
                  name            : r['title'],
                  isFavorite      : r['isFav'] ?? false,  //coeur rouge si favori
                  onFavoriteChanged: (_) {},
                );

                return GestureDetector(
                  onTap: () {
                    if (r['type'] == 'product') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ItemPageCustomer(productId: r['id']),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StorePageCustomer(storeId: r['id']),
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
      return const Center(
        child: Text('No result ',
            style: TextStyle(fontSize: 18, color: Colors.black54)),
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
          title:
          Text(it['title'], style: const TextStyle(color: Colors.black)),
          subtitle: Text(it['subtitle'],
              style: const TextStyle(color: Colors.black54)),
          onTap: () {
            if (isProd) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                    builder: (_) => ItemPageCustomer(productId: it['id'])),
              );
            } else {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                    builder: (_) => StorePageCustomer(storeId: it['id'])),
              );
            }
          },
        );
      },
    );
  }
}
