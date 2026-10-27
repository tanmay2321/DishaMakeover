import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../models/product_model.dart';

class AddEditProductDialog extends StatefulWidget {
  final ProductModel? product;
  final ValueChanged<ProductModel> onSave;

  const AddEditProductDialog({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  static const _uuid = Uuid();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockController;
  late TextEditingController _unitController;
  late String _category;

  final List<String> _categories = [
    'Skin Care',
    'Hair Care',
    'Makeup & Cosmetics',
    'Salon Services',
    'Bridal Package',
    'Organic Products',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _costPriceController = TextEditingController(
      text: p != null && p.costPrice > 0 ? p.costPrice.toStringAsFixed(0) : '',
    );
    _stockController = TextEditingController(text: p != null ? p.stockQuantity.toString() : '50');
    _unitController = TextEditingController(text: p?.unit ?? 'pcs');
    _category = p?.category ?? 'Skin Care';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final costPrice = double.tryParse(_costPriceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 50;
    final unit = _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a product name'), backgroundColor: AppColors.wineAccent),
      );
      return;
    }

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price'), backgroundColor: AppColors.wineAccent),
      );
      return;
    }

    final product = ProductModel(
      id: widget.product?.id ?? _uuid.v4(),
      name: name,
      category: _category,
      price: price,
      costPrice: costPrice,
      stockQuantity: stock,
      unit: unit,
      usageCount: widget.product?.usageCount ?? 0,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    widget.onSave(product);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Dialog(
      backgroundColor: AppColors.bgElevated.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.goldPrimary, width: 1.5),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.winePrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isEditing ? Icons.edit : Icons.add_business,
                    color: AppColors.goldLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isEditing ? 'Edit Product / Service' : 'Add New Product / Service',
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.glassBorderGold, height: 24),
            GlassTextField(
              controller: _nameController,
              label: 'Product / Service Name',
              hint: 'e.g. O3+ Facial Kit, Keratin Treatment',
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category',
                  style: TextStyle(color: AppColors.textGold, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.glassWhiteStrong,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.glassBorderGold.withValues(alpha: 0.4)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _category,
                      dropdownColor: AppColors.bgElevated,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.goldPrimary),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlassTextField(
                    controller: _priceController,
                    label: 'Selling Price (₹)',
                    hint: 'e.g. 1200',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.goldPrimary, size: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassTextField(
                    controller: _costPriceController,
                    label: 'Cost Price (₹)',
                    hint: 'Optional',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(Icons.money_off, color: AppColors.textMuted, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlassTextField(
                    controller: _stockController,
                    label: 'Stock Quantity',
                    hint: '50',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassTextField(
                    controller: _unitController,
                    label: 'Unit',
                    hint: 'pcs / kit / session',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                const SizedBox(width: 12),
                GlassButton(
                  onPressed: _submit,
                  label: isEditing ? 'Update' : 'Save to Catalog',
                  variant: GlassButtonVariant.primaryGold,
                  height: 42,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
