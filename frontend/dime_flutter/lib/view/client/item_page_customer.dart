import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../../vm/client/search_client_vm.dart';

class ItemPageCustomer extends StatelessWidget {
  final int productId;
  final String? locatedStoreName;

  const ItemPageCustomer({
    super.key,
    required this.productId,
    this.locatedStoreName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ItemPageViewModel(
            productId: productId,
            auth: context.read<AuthViewModel>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchPageViewModel(
            auth: context.read<AuthViewModel>(),
          ),
        ),
      ],
      child: Consumer<ItemPageViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.error != null) {
            return Scaffold(
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
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProductHeader(vm: vm, locatedStoreName: locatedStoreName),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Commerces With This Item',
                      style: AppTextStyles.title.copyWith(fontSize: 18)

                    ),
                  ),
                  const SizedBox(height: 12),
                  if (vm.storesForSection.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No stores found',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    _StoresSection(vm: vm, productId: productId),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'You May Also Like',
                      style: AppTextStyles.title.copyWith(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SimilarItemsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
          );
        },
      ),
    );
  }
}

/* ──────────── PRODUCT HEADER ──────────── */
class _ProductHeader extends StatelessWidget {
  const _ProductHeader({
    required this.vm,
    required this.locatedStoreName,
  });

  final ItemPageViewModel vm;
  final String? locatedStoreName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /* Product Image */
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: vm.product?['image_url'] != null
                  ? Image.network(
                vm.product!['image_url'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.broken_image,
                  size: 48,
                  color: Colors.grey[400],
                ),
              )
                  : Icon(
                Icons.shopping_bag,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /* Product Name */
          Text(
            vm.productName,
            style: AppTextStyles.title.copyWith(fontSize: 22),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          /* Barcode */
          Text(
            vm.barCode.isNotEmpty
                ? 'Barcode : ${vm.barCode}'
                : 'Barcode not available',
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          /*shelf*/
           _buildShelfPreview(context, vm),

          const SizedBox(height: 16),
          /* Price and Rating Row */
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (vm.minPrice != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${vm.minPrice!.toStringAsFixed(2)}',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 18,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '5.0',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              /* Favorite Button */
              GestureDetector(
                onTap: vm.toggleFavorite,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: vm.isFavorite ? Colors.red[50] : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    vm.isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 24,
                    color: vm.isFavorite ? Colors.red : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),

          /* Located At (if available) */
          if (locatedStoreName != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Located at: ',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final match = vm.storesWithPrice.firstWhere(
                          (e) => e['store_name'] == locatedStoreName,
                      orElse: () => {},
                    );
                    if (match.isNotEmpty) {
                      final int storeId = match['store_id'] as int;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StorePageCustomer(storeId: storeId),
                        ),
                      );
                    }
                  },
                  child: Text(
                    locatedStoreName!,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildShelfPreview(BuildContext context, ItemPageViewModel vm) {
    print(vm.shelfImageUrl);
    if (vm.shelfImageUrl.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) {
              final size = MediaQuery.of(ctx).size;
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: size.width,
                  height: size.height * 0.85,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.black,
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Image.network(
                            vm.shelfImageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  vm.shelfImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image,
                    size: 24,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                vm.shelfName.isNotEmpty ? vm.shelfName : 'Shelf',
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        vm.shelfName.isNotEmpty ? 'Associated Shelf : ${vm.shelfName}' : 'Shelf not available',
        style: AppTextStyles.body.copyWith(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        textAlign: TextAlign.center,
      );
    }
  }
}

/* ──────────── STORES SECTION ──────────── */
class _StoresSection extends StatelessWidget {
  const _StoresSection({
    required this.vm,
    required this.productId,
  });

  final ItemPageViewModel vm;
  final int productId;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: vm.storesForSection.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final store = vm.storesForSection[i];
        final isFavorite = vm.favoriteStoreIds.contains(
          store['store_id'] as int,
        );
        final isPromo = store['isPromo'] == true;

        return Card(
          color: Colors.grey[100],
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              final int storeId = store['store_id'] as int;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StorePageCustomer(storeId: storeId),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  /* Favorite Icon */
                  Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey[400],
                    size: 20,
                  ),
                  const SizedBox(width: 12),

                  /* Store Name */
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store['store_name'] ?? 'Unknown Store',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isPromo && store['promoTitle'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                store['promoTitle'],
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  /* Price */
                  GestureDetector(
                    onTap: () {
                      final int pid = store['product_id'] as int;
                      if (pid != productId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemPageCustomer(
                              productId: pid,
                              locatedStoreName: store['store_name'] as String,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPromo ? Colors.red : Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '\$${(store['price'] as num).toStringAsFixed(2)}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ──────────── SIMILAR ITEMS SECTION ──────────── */
class _SimilarItemsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchPageViewModel>(
      builder: (context, vm, _) {
        final similarItems = vm.filteredProducts.take(6).toList();
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
          itemCount: similarItems.length,
          itemBuilder: (_, i) {
            final item = similarItems[i];
            return _SimilarItemCard(product: item);
          },
        );
      },
    );
  }
}


/* ──────────── SIMILAR ITEM CARD ──────────── */
class _SimilarItemCard extends StatelessWidget {
  const _SimilarItemCard({required this.product});

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
            /* Image + Favorite Button */
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
                ],
              ),
            ),

            /* Product Info */
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