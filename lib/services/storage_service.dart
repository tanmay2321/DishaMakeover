import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_profile_model.dart';
import '../models/customer_model.dart';
import '../models/invoice_model.dart';
import '../models/product_model.dart';
import 'sample_data_service.dart';

class StorageService {
  static const String _keyProducts = 'dm_products';
  static const String _keyCustomers = 'dm_customers';
  static const String _keyInvoices = 'dm_invoices';
  static const String _keyBusiness = 'dm_business';
  static const String _keyInvoiceCounter = 'dm_invoice_counter';
  static const String _keyFirebaseConfig = 'dm_firebase_config';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);
    await service._seedInitialDataIfNeeded();
    return service;
  }

  Future<void> _seedInitialDataIfNeeded() async {
    if (!_prefs.containsKey(_keyProducts)) {
      final initialProducts = SampleDataService.getInitialProducts();
      await saveProducts(initialProducts);
    }
    if (!_prefs.containsKey(_keyCustomers)) {
      final initialCustomers = SampleDataService.getInitialCustomers();
      await saveCustomers(initialCustomers);
    }
    if (!_prefs.containsKey(_keyBusiness)) {
      await saveBusinessProfile(const BusinessProfileModel());
    }
    if (!_prefs.containsKey(_keyInvoiceCounter)) {
      await _prefs.setInt(_keyInvoiceCounter, 1);
    }
  }

  // --- Products ---
  List<ProductModel> getProducts() {
    final jsonStr = _prefs.getString(_keyProducts);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error decoding products: $e');
      return [];
    }
  }

  Future<void> saveProducts(List<ProductModel> products) async {
    final jsonStr = jsonEncode(products.map((p) => p.toJson()).toList());
    await _prefs.setString(_keyProducts, jsonStr);
  }

  Future<void> upsertProduct(ProductModel product) async {
    final products = getProducts();
    final index = products.indexWhere(
      (p) => p.id == product.id || p.name.trim().toLowerCase() == product.name.trim().toLowerCase(),
    );
    if (index >= 0) {
      products[index] = product;
    } else {
      products.insert(0, product);
    }
    await saveProducts(products);
  }

  // --- Customers ---
  List<CustomerModel> getCustomers() {
    final jsonStr = _prefs.getString(_keyCustomers);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => CustomerModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error decoding customers: $e');
      return [];
    }
  }

  Future<void> saveCustomers(List<CustomerModel> customers) async {
    final jsonStr = jsonEncode(customers.map((c) => c.toJson()).toList());
    await _prefs.setString(_keyCustomers, jsonStr);
  }

  Future<void> upsertCustomer(CustomerModel customer) async {
    final customers = getCustomers();
    final index = customers.indexWhere(
      (c) => c.id == customer.id || (c.phone.isNotEmpty && c.phone == customer.phone),
    );
    if (index >= 0) {
      customers[index] = customer;
    } else {
      customers.insert(0, customer);
    }
    await saveCustomers(customers);
  }

  // --- Invoices ---
  List<InvoiceModel> getInvoices() {
    final jsonStr = _prefs.getString(_keyInvoices);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      final invoices = list
          .map((item) => InvoiceModel.fromJson(item as Map<String, dynamic>))
          .toList();
      invoices.sort((a, b) => b.date.compareTo(a.date));
      return invoices;
    } catch (e) {
      debugPrint('Error decoding invoices: $e');
      return [];
    }
  }

  Future<void> saveInvoices(List<InvoiceModel> invoices) async {
    final jsonStr = jsonEncode(invoices.map((i) => i.toJson()).toList());
    await _prefs.setString(_keyInvoices, jsonStr);
  }

  Future<void> addInvoice(InvoiceModel invoice) async {
    final invoices = getInvoices();
    invoices.insert(0, invoice);
    await saveInvoices(invoices);

    // Auto-update or auto-create customer stats
    final customers = getCustomers();
    final custIndex = customers.indexWhere(
      (c) => c.id == invoice.customer.id || (c.phone.isNotEmpty && c.phone == invoice.customer.phone),
    );
    if (custIndex >= 0) {
      final existing = customers[custIndex];
      customers[custIndex] = existing.copyWith(
        name: invoice.customer.name,
        address: invoice.customer.address.isNotEmpty ? invoice.customer.address : existing.address,
        totalSpent: existing.totalSpent + invoice.grandTotal,
        totalInvoices: existing.totalInvoices + 1,
        lastVisit: invoice.date,
      );
    } else {
      customers.insert(
        0,
        invoice.customer.copyWith(
          totalSpent: invoice.grandTotal,
          totalInvoices: 1,
          lastVisit: invoice.date,
        ),
      );
    }
    await saveCustomers(customers);

    // Auto-save any new products entered in invoice items
    final products = getProducts();
    for (final item in invoice.items) {
      final prodIndex = products.indexWhere(
        (p) => (item.productId != null && p.id == item.productId) ||
            p.name.trim().toLowerCase() == item.name.trim().toLowerCase(),
      );

      if (prodIndex >= 0) {
        // Increment usage count and update recent price
        final existingProd = products[prodIndex];
        products[prodIndex] = existingProd.copyWith(
          price: item.unitPrice,
          category: item.category.isNotEmpty ? item.category : existingProd.category,
          usageCount: existingProd.usageCount + 1,
        );
      } else {
        // Automatically save new product so owner never has to type it again!
        final newProd = ProductModel(
          id: item.productId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: item.name.trim(),
          category: item.category.trim().isEmpty ? 'General' : item.category.trim(),
          price: item.unitPrice,
          costPrice: 0.0,
          stockQuantity: 50,
          unit: 'pcs',
          usageCount: 1,
          createdAt: DateTime.now(),
        );
        products.insert(0, newProd);
      }
    }
    await saveProducts(products);
  }

  // Next Invoice Number Generator: DM-YYYY-0001
  Future<String> getNextInvoiceNumber() async {
    final counter = _prefs.getInt(_keyInvoiceCounter) ?? 1;
    final year = DateTime.now().year;
    final formattedNumber = 'DM-$year-${counter.toString().padLeft(4, '0')}';
    return formattedNumber;
  }

  Future<void> incrementInvoiceCounter() async {
    final counter = _prefs.getInt(_keyInvoiceCounter) ?? 1;
    await _prefs.setInt(_keyInvoiceCounter, counter + 1);
  }

  // --- Business Profile ---
  BusinessProfileModel getBusinessProfile() {
    final jsonStr = _prefs.getString(_keyBusiness);
    if (jsonStr == null || jsonStr.isEmpty) {
      return const BusinessProfileModel();
    }
    try {
      return BusinessProfileModel.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      return const BusinessProfileModel();
    }
  }

  Future<void> saveBusinessProfile(BusinessProfileModel profile) async {
    await _prefs.setString(_keyBusiness, jsonEncode(profile.toJson()));
  }

  // --- Firebase Config ---
  Map<String, dynamic> getFirebaseConfig() {
    final jsonStr = _prefs.getString(_keyFirebaseConfig);
    if (jsonStr == null || jsonStr.isEmpty) {
      return {
        'projectId': 'disha-makeover-app',
        'apiKey': '',
        'databaseUrl': '',
        'isEnabled': false,
        'lastSync': null,
      };
    }
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return {'projectId': 'disha-makeover-app', 'isEnabled': false};
    }
  }

  Future<void> saveFirebaseConfig(Map<String, dynamic> config) async {
    await _prefs.setString(_keyFirebaseConfig, jsonEncode(config));
  }
}
