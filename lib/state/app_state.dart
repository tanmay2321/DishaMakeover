import 'package:flutter/foundation.dart';
import '../models/business_profile_model.dart';
import '../models/customer_model.dart';
import '../models/invoice_model.dart';
import '../models/product_model.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../services/pdf_invoice_service.dart';

class AppState extends ChangeNotifier {
  final StorageService storageService;
  final FirebaseService firebaseService;

  List<ProductModel> _products = [];
  List<CustomerModel> _customers = [];
  List<InvoiceModel> _invoices = [];
  BusinessProfileModel _businessProfile = const BusinessProfileModel();
  bool _isLoading = false;
  String? _errorMessage;

  AppState({
    required this.storageService,
    required this.firebaseService,
  }) {
    loadAllData();
  }

  List<ProductModel> get products => _products;
  List<CustomerModel> get customers => _customers;
  List<InvoiceModel> get invoices => _invoices;
  BusinessProfileModel get businessProfile => _businessProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Dashboard Metrics ---
  double get todaySales {
    final now = DateTime.now();
    return _invoices
        .where((inv) =>
            inv.date.year == now.year &&
            inv.date.month == now.month &&
            inv.date.day == now.day)
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);
  }

  double get thisMonthSales {
    final now = DateTime.now();
    return _invoices
        .where((inv) => inv.date.year == now.year && inv.date.month == now.month)
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);
  }

  double get totalRevenue =>
      _invoices.fold(0.0, (sum, inv) => sum + inv.grandTotal);

  double get totalPendingDue =>
      _invoices.fold(0.0, (sum, inv) => sum + inv.balanceDue);

  int get totalInvoicesCount => _invoices.length;

  int get totalProductsCount => _products.length;

  int get totalCustomersCount => _customers.length;

  List<InvoiceModel> get recentInvoices => _invoices.take(5).toList();

  List<ProductModel> get topSellingProducts {
    final copy = List<ProductModel>.from(_products);
    copy.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return copy.take(6).toList();
  }

  // --- Data Loading ---
  void loadAllData() {
    _isLoading = true;
    notifyListeners();

    _products = storageService.getProducts();
    _customers = storageService.getCustomers();
    _invoices = storageService.getInvoices();
    _businessProfile = storageService.getBusinessProfile();

    _isLoading = false;
    notifyListeners();
  }

  // --- Invoice Creation ---
  Future<String> getNextInvoiceNumber() async {
    return await storageService.getNextInvoiceNumber();
  }

  Future<InvoiceModel> createAndSaveInvoice({
    required CustomerModel customer,
    required List<dynamic> items, // List<InvoiceItemModel>
    required double subtotal,
    required double discountAmount,
    required double taxPercentage,
    required double taxAmount,
    required double grandTotal,
    required double amountPaid,
    required String paymentStatus,
    required String paymentMode,
    required String notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final nextNumber = await storageService.getNextInvoiceNumber();
    final now = DateTime.now();

    final invoice = InvoiceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNumber: nextNumber,
      customer: customer,
      items: items.cast(),
      date: now,
      subtotal: subtotal,
      discountAmount: discountAmount,
      taxPercentage: taxPercentage,
      taxAmount: taxAmount,
      grandTotal: grandTotal,
      amountPaid: amountPaid,
      paymentStatus: paymentStatus,
      paymentMode: paymentMode,
      notes: notes,
      createdAt: now,
    );

    // Save locally
    await storageService.addInvoice(invoice);
    await storageService.incrementInvoiceCounter();

    // Automatically generate and cache PDF
    try {
      final pdfBytes = await PdfInvoiceService.generateInvoicePdf(
        invoice: invoice,
        business: _businessProfile,
      );
      final pdfPath = await PdfInvoiceService.savePdfToFile(
        bytes: pdfBytes,
        invoiceNumber: invoice.invoiceNumber,
      );
      final updatedWithPdf = invoice.copyWith(pdfPath: pdfPath);
      // Update invoice with cached path
      final index = _invoices.indexWhere((i) => i.id == invoice.id);
      if (index >= 0) {
        _invoices[index] = updatedWithPdf;
      }
    } catch (e) {
      debugPrint('Error generating background PDF: $e');
    }

    // Attempt live Firebase sync if enabled
    if (firebaseService.isEnabled) {
      firebaseService.pushInvoiceToCloud(invoice).then((_) {});
    }

    // Refresh state
    loadAllData();
    return invoice;
  }

  // --- Product Management ---
  Future<void> addOrUpdateProduct(ProductModel product) async {
    await storageService.upsertProduct(product);
    if (firebaseService.isEnabled) {
      await firebaseService.pushProductToCloud(product);
    }
    loadAllData();
  }

  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
    await storageService.saveProducts(_products);
    loadAllData();
  }

  // --- Customer Management ---
  Future<void> addOrUpdateCustomer(CustomerModel customer) async {
    await storageService.upsertCustomer(customer);
    loadAllData();
  }

  // --- Business Profile ---
  Future<void> updateBusinessProfile(BusinessProfileModel profile) async {
    _businessProfile = profile;
    await storageService.saveBusinessProfile(profile);
    notifyListeners();
  }

  // --- Firebase Cloud Sync ---
  Future<bool> triggerFullCloudSync() async {
    _isLoading = true;
    notifyListeners();
    final success = await firebaseService.syncAllToCloud();
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> updateFirebaseConfig({
    required String projectId,
    required bool isEnabled,
  }) async {
    firebaseService.projectId = projectId;
    firebaseService.isEnabled = isEnabled;
    await storageService.saveFirebaseConfig({
      'projectId': projectId,
      'isEnabled': isEnabled,
      'lastSync': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }
}
