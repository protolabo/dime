import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dime_flutter/view/styles.dart';

import 'package:dime_flutter/vm/client/store_page_vm.dart';
import 'package:dime_flutter/view/components/header_client.dart';
import 'package:dime_flutter/view/components/nav_bar_client.dart';
import 'package:dime_flutter/view/client/item_page_customer.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';
import 'package:dime_flutter/view/client/search_page_client.dart';

import '../../auth_viewmodel.dart';

class StorePageCustomer extends StatelessWidget {
  const StorePageCustomer({super.key, required this.storeId});
  final int storeId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StorePageVM(auth: context.read<AuthViewModel>())
        ..load(storeId),
      child: Consumer<StorePageVM>(
        builder: (ctx, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.error != null) {
            return Scaffold(
              appBar: const Header(null),
              body: Center(
                child: Text(
                  'Error: ${vm.error}',
                  style: AppTextStyles.body,
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const Header(null),
            bottomNavigationBar: navbar_client(
              currentIndex: 3,
              onTap: (i) {
                if (i == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavoriteMenuPage(),
                    ),
                  );
                } else if (i == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScanClientPage(),
                    ),
                  );
                } else if (i == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchPage(),
                    ),
                  );
                }
              },
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /* ---------- STORE HEADER ---------- */
                    _StoreHeader(vm: vm, storeId: storeId),

                    const SizedBox(height: 24),

                    /* ---------- RECOMMENDATIONS ---------- */
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Items from the store you may like',
                        style: AppTextStyles.title.copyWith(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (vm.recos.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recommendations available',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      _RecommendationsGrid(vm: vm),

                    const SizedBox(height: 24),
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

/* ──────────── STORE HEADER ──────────── */
class _StoreHeader extends StatelessWidget {
  const _StoreHeader({
    required this.vm,
    required this.storeId,
  });

  final StorePageVM vm;
  final int storeId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /* Store Icon */
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store,
              size: 48,
              color: Colors.blue[700],
            ),
          ),

          const SizedBox(height: 16),

          /* Store Name */
          Text(
            vm.storeName ?? 'Unknown Store',
            style: AppTextStyles.title.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          /* Address */
          Text(
            vm.address ?? 'Address not available',
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          /* Favorite Button */
          GestureDetector(
            onTap: () => vm.toggleFavorite(storeId),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: vm.isStoreFavorite ? Colors.red[50] : Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: vm.isStoreFavorite ? Colors.red : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    vm.isStoreFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: vm.isStoreFavorite ? Colors.red : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vm.isStoreFavorite
                        ? 'Remove from favorites'
                        : 'Add to favorites',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: vm.isStoreFavorite
                          ? Colors.red
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ──────────── RECOMMENDATIONS GRID ──────────── */
class _RecommendationsGrid extends StatelessWidget {
  const _RecommendationsGrid({required this.vm});

  final StorePageVM vm;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: vm.recos.length,
      itemBuilder: (_, i) {
        final product = vm.recos[i];
        return _ProductCard(product: product);
      },
    );
  }
}

/* ──────────── PRODUCT CARD ──────────── */
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemPageCustomer(productId: product['id']),
          ),
        );
      },
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
                      onTap: () {
                        // vm.toggleProductFavorite(product['id']);
                      },
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
                          product['isFav'] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: product['isFav'] == true
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
                    product['title'] ?? 'Product',
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