import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/invoice_model.dart';
import '../models/product_model.dart';
import 'storage_service.dart';

enum CloudSyncStatus { connected, offline, syncing, error }

class FirebaseService {
  final StorageService storageService;
  String projectId;
  bool isEnabled;

  FirebaseService({
    required this.storageService,
    this.projectId = 'disha-makeover-app',
    this.isEnabled = false,
  });

  static FirebaseService fromStorage(StorageService storage) {
    final config = storage.getFirebaseConfig();
    return FirebaseService(
      storageService: storage,
      projectId: config['projectId'] as String? ?? 'disha-makeover-app',
      isEnabled: config['isEnabled'] as bool? ?? false,
    );
  }

  String get _firestoreBaseUrl =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  /// Converts a standard Dart map to Firestore REST Document fields format
  static Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> map) {
    final fields = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is String) {
        fields[key] = {'stringValue': value};
      } else if (value is int) {
        fields[key] = {'integerValue': value.toString()};
      } else if (value is double) {
        fields[key] = {'doubleValue': value};
      } else if (value is num) {
        fields[key] = {'doubleValue': value.toDouble()};
      } else if (value is bool) {
        fields[key] = {'booleanValue': value};
      } else if (value is Map<String, dynamic>) {
        fields[key] = {'mapValue': {'fields': _toFirestoreFields(value)}};
      } else if (value is List) {
        final listValues = value.map((item) {
          if (item is Map<String, dynamic>) {
            return {'mapValue': {'fields': _toFirestoreFields(item)}};
          } else if (item is String) {
            return {'stringValue': item};
          } else if (item is num) {
            return {'doubleValue': item.toDouble()};
          }
          return {'stringValue': item.toString()};
        }).toList();
        fields[key] = {'arrayValue': {'values': listValues}};
      } else if (value == null) {
        fields[key] = {'nullValue': null};
      } else {
        fields[key] = {'stringValue': value.toString()};
      }
    });
    return fields;
  }

  /// Pushes an invoice live to Firestore: collection `invoices/{invoiceNumber}`
  Future<bool> pushInvoiceToCloud(InvoiceModel invoice) async {
    if (!isEnabled || projectId.isEmpty) return false;
    try {
      final docId = invoice.invoiceNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final url = Uri.parse('$_firestoreBaseUrl/invoices/$docId');
      final body = jsonEncode({
        'fields': _toFirestoreFields(invoice.toJson()),
      });

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('Invoice successfully synced to Firebase: ${invoice.invoiceNumber}');
        return true;
      } else {
        debugPrint('Firebase sync error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Firebase push invoice failed: $e');
      return false;
    }
  }

  /// Pushes a product live to Firestore: collection `products/{id}`
  Future<bool> pushProductToCloud(ProductModel product) async {
    if (!isEnabled || projectId.isEmpty) return false;
    try {
      final url = Uri.parse('$_firestoreBaseUrl/products/${product.id}');
      final body = jsonEncode({
        'fields': _toFirestoreFields(product.toJson()),
      });

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Firebase push product failed: $e');
      return false;
    }
  }

  /// Sync all local products, invoices, and customers to Cloud
  Future<bool> syncAllToCloud() async {
    if (!isEnabled || projectId.isEmpty) return false;
    try {
      final products = storageService.getProducts();
      final invoices = storageService.getInvoices();
      final customers = storageService.getCustomers();

      for (final p in products) {
        await pushProductToCloud(p);
      }
      for (final inv in invoices) {
        await pushInvoiceToCloud(inv);
      }
      for (final c in customers) {
        final url = Uri.parse('$_firestoreBaseUrl/customers/${c.id}');
        final body = jsonEncode({'fields': _toFirestoreFields(c.toJson())});
        await http.patch(url, headers: {'Content-Type': 'application/json'}, body: body);
      }

      await storageService.saveFirebaseConfig({
        'projectId': projectId,
        'isEnabled': isEnabled,
        'lastSync': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Full sync to Cloud failed: $e');
      return false;
    }
  }

  /// Test connection to Firebase project
  Future<bool> testConnection(String testProjectId) async {
    try {
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$testProjectId/databases/(default)/documents',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 6));
      return response.statusCode == 200 || response.statusCode == 404 || response.statusCode == 403;
    } catch (e) {
      return false;
    }
  }
}
