import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/view/components/header_client.dart';
import 'package:dime_flutter/view/components/nav_bar_client.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';
import 'package:dime_flutter/view/client/item_page_customer.dart';
import 'package:dime_flutter/view/client/store_page_customer.dart';
import 'package:dime_flutter/view/client/search_page_client.dart';

import 'package:dime_flutter/vm/client/favorite_menu_vm.dart';

import '../../auth_viewmodel.dart';

class FavoriteMenuPage extends StatefulWidget {
  const FavoriteMenuPage({super.key});

  @override
  State<FavoriteMenuPage> createState() => _FavoriteMenuPageState();
}

class _FavoriteMenuPageState extends State<FavoriteMenuPage> {
  late final FavoriteMenuVM _vm;
  String _selectedFilter = 'Products';

  @override
  void initState() {
    super.initState();
    _vm = FavoriteMenuVM(auth: context.read<AuthViewModel>())..init();
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
            backgroundColor: Colors.white,
            appBar: const Header(null),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  /* ----------- TITLE ----------- */
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Favorite Menu',
                      style: AppTextStyles.title.copyWith(fontSize: 24),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /* ----------- FILTER CHIPS ----------- */
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Products',
                          icon: Icons.shopping_bag_outlined,
                          isSelected: _selectedFilter == 'Products',
                          onTap: () {
                            setState(() => _selectedFilter = 'Products');
                          },
                        ),
                        const SizedBox(width: 12),
                        _FilterChip(
                          label: 'Stores',
                          icon: Icons.store_outlined,
                          isSelected: _selectedFilter == 'Stores',
                          onTap: () {
                            setState(() => _selectedFilter = 'Stores');
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /* ----------- CONTENT ----------- */
                  Expanded(
                    child: _selectedFilter == 'Products'
                        ? _FavoriteProductsGrid(vm: vm)
                        : _FavoriteStoresList(vm: vm),
                  ),
                ],
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

/* ──────────── FAVORITE PRODUCTS GRID ──────────── */
class _FavoriteProductsGrid extends StatelessWidget {
  const _FavoriteProductsGrid({required this.vm});
  final FavoriteMenuVM vm;

  @override
  Widget build(BuildContext context) {
    if (vm.favoriteProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'You don\'t have any favorite items.',
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: vm.favoriteProducts.length,
      itemBuilder: (_, i) {
        final product = vm.favoriteProducts[i];

        return _ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemPageCustomer(productId: product['id']),
              ),
            );
          },
          onFavoriteToggle: () {
            final currentFav = product['isFavorite'] ?? true;
            vm.toggleFavoriteProduct(product['id'], !currentFav);
          },
        );
      },
    );
  }
}

/* ──────────── FAVORITE STORES LIST ──────────── */
class _FavoriteStoresList extends StatelessWidget {
  const _FavoriteStoresList({required this.vm});
  final FavoriteMenuVM vm;

  @override
  Widget build(BuildContext context) {
    if (vm.favoriteStores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'You don\'t have any favorite commerces.',
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: vm.favoriteStores.length,
      itemBuilder: (ctx, i) {
        final store = vm.favoriteStores[i];

        return Card(
          color: Colors.grey.shade100,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.store,
                color: Colors.blue[700],
              ),
            ),
            title: Text(
              store['name'] ?? 'Unknown Store',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${store['address'] ?? ''},${store['city'] ?? ''},${store['country'] ?? ''},${store['postal_code'] ?? ''} '.trim(),
              style: AppTextStyles.body.copyWith(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                store['isFavorite'] == true ? Icons.favorite : Icons.favorite_border,
                color: store['isFavorite'] == true ? Colors.red : Colors.black54,
              ),
              onPressed: () {
                final currentFav = store['isFavorite'] ?? true;
                vm.toggleFavoriteStore(store['id'], !currentFav);
              },
            ),
            onTap: () {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => StorePageCustomer(storeId: store['id']),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/* ──────────── FILTER CHIP WIDGET ──────────── */
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ──────────── PRODUCT CARD WIDGET ──────────── */
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* -------- IMAGE + FAVORITE BUTTON -------- */
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: product['image'] != null
                        ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        product['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.shopping_bag,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                        : Icon(
                      Icons.shopping_bag,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          product['isFavorite'] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: product['isFavorite'] == true
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /* -------- PRODUCT INFO -------- */
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Product',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product['rating']?.toStringAsFixed(1) ?? '5.0',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}