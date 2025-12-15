import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dime_flutter/view/styles.dart';
import 'package:dime_flutter/view/components/header_client.dart';
import 'package:dime_flutter/view/components/nav_bar_client.dart';
import 'package:dime_flutter/view/client/item_page_customer.dart';
import 'package:dime_flutter/view/client/store_page_customer.dart';
import 'package:dime_flutter/view/client/favorite_menu.dart';
import 'package:dime_flutter/view/client/scan_page_client.dart';
import 'package:dime_flutter/vm/client/search_client_vm.dart';
import '../../auth_viewmodel.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _selectedFilter = 'Products';
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(BuildContext ctx, String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
          () => ctx.read<SearchPageViewModel>().query(value,_selectedFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchPageViewModel(auth: context.read<AuthViewModel>()),
      child: Consumer<SearchPageViewModel>(
        builder: (ctx, vm, _) => Scaffold(
          backgroundColor: Colors.white,
          appBar: const Header(null),
          bottomNavigationBar: navbar_client(
            currentIndex: 3,
            onTap: (i) {
              if (i == 1) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ScanClientPage()));
              } else if (i == 0) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FavoriteMenuPage()));
              }
            },
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                /* -------- SEARCH BAR -------- */
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _onSearchChanged(ctx, val),
                    decoration: InputDecoration(
                      hintText: 'Search products or stores...',
                      hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          vm.query('', _selectedFilter);
                          setState(() {});
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: AppColors.searchBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /* -------- FILTER CHIPS + STORE FILTER -------- */
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'Products',
                                icon: Icons.shopping_bag_outlined,
                                isSelected: _selectedFilter == 'Products',
                                onTap: () {
                                  setState(() => _selectedFilter = 'Products');
                                  if (_searchController.text.isNotEmpty) {
                                    vm.query(_searchController.text, 'Products');
                                  } else {
                                    vm.filterProducts('Products');
                                  }
                                },
                              ),
                              const SizedBox(width: 12),
                              _FilterChip(
                                label: 'Stores',
                                icon: Icons.store_outlined,
                                isSelected: _selectedFilter == 'Stores',
                                onTap: () {
                                  setState(() => _selectedFilter = 'Stores');
                                  if (_searchController.text.isNotEmpty) {
                                    vm.query(_searchController.text, 'Stores');
                                  } else {
                                    vm.showAllStores();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      /* Store Location Filter Button - Hidden for Stores filter */
                      if (_selectedFilter == 'Products')
                        GestureDetector(
                          onTap: () => _showStoreFilterDialog(context, vm),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: vm.storeFilterEnabled
                                  ? Colors.blue[50]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: vm.storeFilterEnabled
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Badge(
                              isLabelVisible: vm.storeFilterEnabled,
                              label: const Text('1'),
                              child: Icon(
                                Icons.tune,
                                size: 20,
                                color: vm.storeFilterEnabled
                                    ? Colors.blue
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /* -------- CONTENT -------- */
                Expanded(
                  child: _searchController.text.isNotEmpty
                      ? _SearchResults(vm: vm)
                      : _ProductsGridView(
                    vm: vm,
                    selectedFilter: _selectedFilter,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showStoreFilterDialog(BuildContext context, SearchPageViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Filter by Store',
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),

                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.store_mall_directory),
                title: const Text('All Stores'),
                trailing: vm.storeFilterEnabled
                    ? null
                    : const Icon(Icons.check, color: Colors.blue),
                onTap: () {
                  vm.clearStoreFilter();
                  if (_searchController.text.isNotEmpty) {
                    vm.query(_searchController.text, _selectedFilter);
                  }
                  Navigator.pop(ctx);
                },
              ),
              const Divider(),
              Flexible(

                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: vm.availableStores.length,
                  itemBuilder: (_, i) {

                    final store = vm.availableStores[i];
                    final isSelected = vm.selectedStoreId == store['id'];
                    return ListTile(

                      leading: const Icon(Icons.store),
                      title: Text(store['name'] ?? 'Unknown Store'),
                      subtitle: store['city'] != null
                          ? Text(store['city'])
                          : null,
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        vm.filterByStore(store['id'], store['name']);
                        if (_searchController.text.isNotEmpty) {
                          vm.query(_searchController.text, _selectedFilter);
                        }
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ──────────── PRODUCTS GRID VIEW ──────────── */
class _ProductsGridView extends StatelessWidget {
  const _ProductsGridView({
    required this.vm,
    required this.selectedFilter,
  });

  final SearchPageViewModel vm;
  final String selectedFilter;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show stores list when Stores filter is selected
    if (selectedFilter == 'Stores') {
      return _AllStoresList(vm: vm);
    }

    if (vm.filteredProducts.isEmpty) {
      return Center(
        child: Text(
          'No products available',
          style: AppTextStyles.body.copyWith(
            fontSize: 16,
            color: Colors.grey,
          ),
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
      itemCount: vm.filteredProducts.length,
      itemBuilder: (_, i) {
        final product = vm.filteredProducts[i];
        return _ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemPageCustomer(
                  productId: product['id'],
                ),
              ),
            );
          },
          onFavoriteToggle: () {
            vm.toggleFavorite(product['id']);
          },
        );
      },
    );
  }
}

/* ──────────── ALL STORES LIST ──────────── */
class _AllStoresList extends StatelessWidget {
  const _AllStoresList({required this.vm});
  final SearchPageViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.availableStores.isEmpty) {
      return Center(
        child: Text(
          'No stores available',
          style: AppTextStyles.body.copyWith(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: vm.availableStores.length,
      itemBuilder: (ctx, i) {
        final store = vm.availableStores[i];
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
              '${store['city'] ?? ''} ${store['country'] ?? ''}'.trim(),
              style: AppTextStyles.body.copyWith(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

/* ──────────── SEARCH RESULTS ──────────── */
class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.vm});
  final SearchPageViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.searchResults.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: AppTextStyles.body.copyWith(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: vm.searchResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final item = vm.searchResults[i];
        final isProd = item['type'] == 'product';

        return ListTile(
          leading: Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50] ,
                borderRadius: BorderRadius.circular(8),
              ),
              child: item['image_url']  != null && item['image_url'] !.isNotEmpty
                  ? Image.network(item['image_url'] !, width: 70, height: 70, fit: BoxFit.contain)
                  : Icon(
          isProd ? Icons.shopping_bag : Icons.store,
           color: isProd ? Colors.blue[700] : Colors.green[700],
              ),
              ),
          title: Text(
            item['title'],
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            item['subtitle'],
            style: AppTextStyles.body.copyWith(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              item['isFav'] == true ? Icons.favorite : Icons.favorite_border,
              color: item['isFav'] == true ? Colors.red : Colors.black54,
            ),
            onPressed: () {
              if (isProd) {
                vm.toggleFavoriteProduct(item['id'], !(item['isFav'] ?? false));
              } else {
                vm.toggleFavoriteStore(item['id'], !(item['isFav'] ?? false));
              }
            },
          ),
          onTap: () {
            if (isProd) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => ItemPageCustomer(productId: item['id']),
                ),
              );
            } else {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => StorePageCustomer(storeId: item['id']),
                ),
              );
            }
          },
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
                        product['price']?.toStringAsFixed(2) != null ? '\$${product['price']?.toStringAsFixed(2)}' : 'Unavailable',
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