import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../models/customer_model.dart';
import '../../models/invoice_item_model.dart';
import '../../models/invoice_model.dart';
import '../../models/product_model.dart';
import '../../state/app_state.dart';
import 'pdf_preview_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final AppState appState;
  final ProductModel? initialProduct;

  const CreateInvoiceScreen({
    super.key,
    required this.appState,
    this.initialProduct,
  });

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  static const _uuid = Uuid();

  // Customer Controllers
  final _customerPhoneController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();

  // Item Form Controllers
  final _productNameController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _itemDiscountController = TextEditingController(text: '0');
  String _selectedCategory = 'Skin Care';
  String? _selectedProductId;

  // Invoice Items
  final List<InvoiceItemModel> _items = [];

  // Summary Modifiers
  double _overallDiscount = 0.0;
  double _taxPercentage = 0.0;
  String _paymentMode = 'UPI / GPay';
  String _paymentStatus = 'Paid';
  final _amountPaidController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSaving = false;
  String _nextInvoiceNumber = 'Loading...';

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
    _fetchNextInvoiceNumber();
    if (widget.initialProduct != null) {
      _selectProduct(widget.initialProduct!);
    }
  }

  Future<void> _fetchNextInvoiceNumber() async {
    final num = await widget.appState.getNextInvoiceNumber();
    if (mounted) setState(() => _nextInvoiceNumber = num);
  }

  @override
  void dispose() {
    _customerPhoneController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _productNameController.dispose();
    _unitPriceController.dispose();
    _quantityController.dispose();
    _itemDiscountController.dispose();
    _amountPaidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onCustomerPhoneChanged(String phone) {
    if (phone.length >= 10) {
      final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final match = widget.appState.customers.firstWhere(
        (c) => c.phone.replaceAll(RegExp(r'[^0-9]'), '').endsWith(clean.length > 10 ? clean.substring(clean.length - 10) : clean),
        orElse: () => CustomerModel(id: '', name: '', phone: '', lastVisit: DateTime.now()),
      );

      if (match.name.isNotEmpty) {
        setState(() {
          _customerNameController.text = match.name;
          if (match.address.isNotEmpty) {
            _customerAddressController.text = match.address;
          }
        });
      }
    }
  }

  void _selectProduct(ProductModel product) {
    setState(() {
      _selectedProductId = product.id;
      _productNameController.text = product.name;
      _unitPriceController.text = product.price.toStringAsFixed(0);
      _selectedCategory = product.category;
    });
  }

  void _addItem() {
    final name = _productNameController.text.trim();
    final price = double.tryParse(_unitPriceController.text.trim()) ?? 0.0;
    final qty = int.tryParse(_quantityController.text.trim()) ?? 1;
    final discount = double.tryParse(_itemDiscountController.text.trim()) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a product or service name'),
          backgroundColor: AppColors.wineAccent,
        ),
      );
      return;
    }

    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: AppColors.wineAccent,
        ),
      );
      return;
    }

    final newItem = InvoiceItemModel(
      id: _uuid.v4(),
      productId: _selectedProductId,
      name: name,
      category: _selectedCategory,
      unitPrice: price,
      quantity: qty > 0 ? qty : 1,
      discount: discount,
    );

    setState(() {
      _items.add(newItem);
      // Reset Item form
      _selectedProductId = null;
      _productNameController.clear();
      _unitPriceController.clear();
      _quantityController.text = '1';
      _itemDiscountController.text = '0';
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _subtotal => _items.fold(0.0, (sum, item) => sum + item.total);

  double get _taxAmount => (_subtotal - _overallDiscount) > 0
      ? ((_subtotal - _overallDiscount) * (_taxPercentage / 100))
      : 0.0;

  double get _grandTotal {
    final afterDiscount = (_subtotal - _overallDiscount) > 0 ? (_subtotal - _overallDiscount) : 0.0;
    return afterDiscount + _taxAmount;
  }

  Future<InvoiceModel?> _saveInvoice() async {
    final customerName = _customerNameController.text.trim();
    final customerPhone = _customerPhoneController.text.trim();

    if (customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter customer name'),
          backgroundColor: AppColors.wineAccent,
        ),
      );
      return null;
    }

    if (customerPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter customer phone number'),
          backgroundColor: AppColors.wineAccent,
        ),
      );
      return null;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product or service'),
          backgroundColor: AppColors.wineAccent,
        ),
      );
      return null;
    }

    setState(() => _isSaving = true);

    try {
      final customer = CustomerModel(
        id: _uuid.v4(),
        name: customerName,
        phone: customerPhone,
        address: _customerAddressController.text.trim(),
        lastVisit: DateTime.now(),
      );

      final paidAmt = _paymentStatus == 'Paid'
          ? _grandTotal
          : (double.tryParse(_amountPaidController.text.trim()) ?? 0.0);

      final invoice = await widget.appState.createAndSaveInvoice(
        customer: customer,
        items: _items,
        subtotal: _subtotal,
        discountAmount: _overallDiscount,
        taxPercentage: _taxPercentage,
        taxAmount: _taxAmount,
        grandTotal: _grandTotal,
        amountPaid: paidAmt,
        paymentStatus: _paymentStatus,
        paymentMode: _paymentMode,
        notes: _notesController.text.trim(),
      );

      return invoice;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save invoice: $e'), backgroundColor: AppColors.wineAccent),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onGenerateAndPreview() async {
    final invoice = await _saveInvoice();
    if (invoice != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewScreen(
            invoice: invoice,
            business: widget.appState.businessProfile,
          ),
        ),
      );
    }
  }

  void _onSendWhatsAppDirect() async {
    final invoice = await _saveInvoice();
    if (invoice != null && mounted) {
      await WhatsAppHelper.sendWhatsAppMessage(
        invoice: invoice,
        business: widget.appState.businessProfile,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.goldPrimary, width: 1.5),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo_round.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New Makeover Invoice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Invoice #$_nextInvoiceNumber',
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Customer Information Card
            _buildCustomerCard(),
            const SizedBox(height: 16),

            // 2. Add Product / Service Card
            _buildAddItemCard(),
            const SizedBox(height: 16),

            // 3. Invoice Items List
            if (_items.isNotEmpty) ...[
              _buildItemsListCard(),
              const SizedBox(height: 16),
            ],

            // 4. Payment & Totals Summary Card
            _buildSummaryCard(),
            const SizedBox(height: 24),

            // 5. Action Buttons (Preview, WhatsApp, Save)
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return GlassCard(
      hasGoldBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, color: AppColors.goldPrimary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Customer Details',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.winePrimary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'Auto-Save Customer',
                  style: TextStyle(color: AppColors.goldLight, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GlassTextField(
            controller: _customerPhoneController,
            label: 'Phone Number (WhatsApp)',
            hint: 'e.g. +91 94281 95591 or 98250 12345',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_iphone_rounded, color: AppColors.goldPrimary, size: 18),
            onChanged: _onCustomerPhoneChanged,
          ),
          const SizedBox(height: 12),
          GlassTextField(
            controller: _customerNameController,
            label: 'Customer Name',
            hint: 'e.g. Priya Shah, Riddhi Patel',
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.goldPrimary, size: 18),
          ),
          const SizedBox(height: 12),
          GlassTextField(
            controller: _customerAddressController,
            label: 'Address / Location (Optional)',
            hint: 'e.g. Anand, Gujarat',
            prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.goldPrimary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemCard() {
    final existingProducts = widget.appState.products;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.add_shopping_cart_rounded, color: AppColors.goldPrimary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Add Beauty Product / Service',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tip: New products you type here will be automatically saved to your catalog for next time!',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 14),

          // Autocomplete Product Name Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Product / Service Name',
                style: TextStyle(
                  color: AppColors.textGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Autocomplete<ProductModel>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return existingProducts.take(6);
                  }
                  return existingProducts.where((p) =>
                      p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (ProductModel option) => option.name,
                onSelected: _selectProduct,
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  // Keep sync with our local controller
                  controller.addListener(() {
                    _productNameController.text = controller.text;
                  });
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.glassWhiteStrong,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.glassBorderGold.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        cursorColor: AppColors.goldPrimary,
                        decoration: const InputDecoration(
                          hintText: 'Type product or search catalog...',
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          prefixIcon: Icon(Icons.search, color: AppColors.goldPrimary, size: 18),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 8,
                      color: Colors.transparent,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 64,
                        constraints: const BoxConstraints(maxHeight: 220),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: AppColors.bgElevated.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.goldPrimary, width: 1.2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 8)),
                          ],
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            return ListTile(
                              dense: true,
                              title: Text(
                                option.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${option.category} • ${CurrencyHelper.format(option.price)}',
                                style: const TextStyle(color: AppColors.goldLight, fontSize: 12),
                              ),
                              trailing: const Icon(Icons.add_circle_outline, color: AppColors.goldPrimary, size: 18),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Category Dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category',
                style: TextStyle(
                  color: AppColors.textGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.glassWhiteStrong,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.glassBorderGold.withValues(alpha: 0.4),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: AppColors.bgElevated,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.goldPrimary),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          cat,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price & Qty Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: GlassTextField(
                  controller: _unitPriceController,
                  label: 'Unit Price (₹)',
                  hint: 'e.g. 850',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.goldPrimary, size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GlassTextField(
                  controller: _quantityController,
                  label: 'Quantity',
                  hint: '1',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.numbers, color: AppColors.goldPrimary, size: 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Add to Invoice Button
          GlassButton(
            onPressed: _addItem,
            label: 'Add Item to Bill',
            icon: const Icon(Icons.add, color: Color(0xFF2A1502), size: 18),
            variant: GlassButtonVariant.primaryGold,
            height: 44,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsListCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items Added (${_items.length})',
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Subtotal: ${CurrencyHelper.format(_subtotal)}',
                style: const TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.glassBorderGold, height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (_, _) => const Divider(color: AppColors.glassBorder, height: 12),
            itemBuilder: (context, index) {
              final item = _items[index];
              return Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.wineAccent.withValues(alpha: 0.4),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${item.category} • ${CurrencyHelper.format(item.unitPrice)} × ${item.quantity}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyHelper.format(item.total),
                    style: const TextStyle(color: AppColors.goldLight, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.statusDue, size: 18),
                    onPressed: () => _removeItem(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return GlassCard(
      hasGoldBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoice Summary & Payment',
            style: TextStyle(
              color: AppColors.goldLight,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),

          // Quick Discount Chips
          const Text(
            'Discount:',
            style: TextStyle(color: AppColors.textGold, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [0.0, 50.0, 100.0, 200.0, 500.0].map((disc) {
              final isSelected = _overallDiscount == disc;
              return ChoiceChip(
                label: Text(disc == 0 ? 'None' : '₹${disc.toInt()}'),
                selected: isSelected,
                selectedColor: AppColors.goldPrimary,
                backgroundColor: AppColors.glassWhite,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (val) {
                  setState(() => _overallDiscount = val ? disc : 0.0);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // GST / Tax Chips
          const Text(
            'Tax / GST:',
            style: TextStyle(color: AppColors.textGold, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [0.0, 5.0, 12.0, 18.0].map((tax) {
              final isSelected = _taxPercentage == tax;
              return ChoiceChip(
                label: Text(tax == 0 ? '0% (Exempt)' : '${tax.toInt()}% GST'),
                selected: isSelected,
                selectedColor: AppColors.wineAccent,
                backgroundColor: AppColors.glassWhite,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (val) {
                  setState(() => _taxPercentage = val ? tax : 0.0);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Payment Mode & Status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Mode',
                      style: TextStyle(color: AppColors.textGold, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _paymentMode,
                      dropdownColor: AppColors.bgElevated,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.glassWhiteStrong,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      items: ['UPI / GPay', 'Cash', 'Card', 'Due / Credit']
                          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentMode = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Status',
                      style: TextStyle(color: AppColors.textGold, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _paymentStatus,
                      dropdownColor: AppColors.bgElevated,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.glassWhiteStrong,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      items: ['Paid', 'Partial', 'Unpaid']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentStatus = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_paymentStatus == 'Partial') ...[
            const SizedBox(height: 10),
            GlassTextField(
              controller: _amountPaidController,
              label: 'Amount Paid Now (₹)',
              hint: 'e.g. 500',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.goldPrimary, size: 18),
            ),
          ],

          const SizedBox(height: 14),

          // Total Calculation Summary Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.wineDark.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.6)),
            ),
            child: Column(
              children: [
                _buildSummaryLine('Subtotal', CurrencyHelper.format(_subtotal)),
                if (_overallDiscount > 0)
                  _buildSummaryLine('Discount', '- ${CurrencyHelper.format(_overallDiscount)}', isRed: true),
                if (_taxAmount > 0)
                  _buildSummaryLine('GST (${_taxPercentage.toInt()}%)', '+ ${CurrencyHelper.format(_taxAmount)}'),
                const Divider(color: AppColors.goldPrimary, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'GRAND TOTAL',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      CurrencyHelper.format(_grandTotal),
                      style: const TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String title, String value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isRed ? AppColors.statusPending : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary: Generate & View PDF
        GlassButton(
          onPressed: _isSaving ? null : _onGenerateAndPreview,
          label: 'Generate & Preview PDF Invoice',
          icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF2A1502), size: 20),
          variant: GlassButtonVariant.primaryGold,
          isLoading: _isSaving,
          height: 52,
        ),
        const SizedBox(height: 12),
        // Secondary: Direct WhatsApp Bill
        GlassButton(
          onPressed: _isSaving ? null : _onSendWhatsAppDirect,
          label: 'Send Invoice on WhatsApp (+91)',
          icon: const Icon(Icons.chat, color: Colors.white, size: 20),
          variant: GlassButtonVariant.whatsapp,
          isLoading: _isSaving,
          height: 50,
        ),
      ],
    );
  }
}
