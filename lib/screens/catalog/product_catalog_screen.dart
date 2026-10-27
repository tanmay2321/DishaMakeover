import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/utils/currency_format.dart';
import '../../models/product_model.dart';
import '../../state/app_state.dart';
import '../invoice/create_invoice_screen.dart';
import 'add_edit_product_dialog.dart';

class ProductCatalogScreen extends StatefulWidget {
  final AppState appState;

  const ProductCatalogScreen({super.key, required this.appState});

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Skin Care',
    'Hair Care',
    'Makeup & Cosmetics',
    'Salon Services',
    'Bridal Package',
    'General',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _filteredProducts {
    final query = _searchController.text.trim().toLowerCase();
    return widget.appState.products.where((p) {
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);

      final matchesCat =
          _selectedCategory == 'All' || p.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesQuery && matchesCat;
    }).toList();
  }

  void _openAddProductDialog([ProductModel? product]) {
    showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(
        product: product,
        onSave: (savedProduct) {
          widget.appState.addOrUpdateProduct(savedProduct);
        },
      ),
    );
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        title: const Text('Delete Product', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove "${product.name}" from your catalog?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.appState.deleteProduct(product.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusDue),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text(
          'Product & Service Catalog',
          style: TextStyle(
            color: AppColors.goldLight,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.goldPrimary, size: 28),
            tooltip: 'Add Product',
            onPressed: () => _openAddProductDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddProductDialog(),
        backgroundColor: AppColors.goldPrimary,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Add Product', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                GlassTextField(
                  controller: _searchController,
                  hint: 'Search cosmetics, facials, serums...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.goldPrimary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                          onPressed: () => setState(() => _searchController.clear()),
                        )
                      : null,
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.goldPrimary,
                          backgroundColor: AppColors.glassWhite,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.spa_outlined, size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        const Text(
                          'No products found in this category',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openAddProductDialog(),
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text('Add New Item', style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Icon / Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.wineGradient,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.glassBorderGold),
                              ),
                              child: const Icon(Icons.spa, color: AppColors.goldLight, size: 24),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.glassWhiteStrong,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          product.category,
                                          style: const TextStyle(color: AppColors.goldLight, fontSize: 10),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Stock: ${product.stockQuantity} ${product.unit}',
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${CurrencyHelper.format(product.price)} / ${product.unit}',
                                    style: const TextStyle(
                                      color: AppColors.goldLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Quick Action: Bill this item
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateInvoiceScreen(
                                          appState: widget.appState,
                                          initialProduct: product,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.wineAccent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text('Bill', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppColors.textGold, size: 18),
                                      onPressed: () => _openAddProductDialog(product),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.statusDue, size: 18),
                                      onPressed: () => _confirmDelete(product),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
