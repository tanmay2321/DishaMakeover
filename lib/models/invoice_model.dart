import 'customer_model.dart';
import 'invoice_item_model.dart';

class InvoiceModel {
  final String id;
  final String invoiceNumber; // e.g. "DM-2026-0001"
  final CustomerModel customer;
  final List<InvoiceItemModel> items;
  final DateTime date;
  final double subtotal;
  final double discountAmount;
  final double taxPercentage; // 0, 5, 12, 18
  final double taxAmount;
  final double grandTotal;
  final double amountPaid;
  final String paymentStatus; // "Paid", "Partial", "Unpaid"
  final String paymentMode; // "UPI / GPay", "Cash", "Card", "Due"
  final String notes;
  final String? pdfPath;
  final DateTime createdAt;

  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customer,
    required this.items,
    required this.date,
    required this.subtotal,
    this.discountAmount = 0.0,
    this.taxPercentage = 0.0,
    this.taxAmount = 0.0,
    required this.grandTotal,
    this.amountPaid = 0.0,
    this.paymentStatus = 'Paid',
    this.paymentMode = 'UPI / GPay',
    this.notes = '',
    this.pdfPath,
    required this.createdAt,
  });

  double get balanceDue => (grandTotal - amountPaid) > 0 ? (grandTotal - amountPaid) : 0.0;

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    CustomerModel? customer,
    List<InvoiceItemModel>? items,
    DateTime? date,
    double? subtotal,
    double? discountAmount,
    double? taxPercentage,
    double? taxAmount,
    double? grandTotal,
    double? amountPaid,
    String? paymentStatus,
    String? paymentMode,
    String? notes,
    String? pdfPath,
    DateTime? createdAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customer: customer ?? this.customer,
      items: items ?? this.items,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxAmount: taxAmount ?? this.taxAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMode: paymentMode ?? this.paymentMode,
      notes: notes ?? this.notes,
      pdfPath: pdfPath ?? this.pdfPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customer': customer.toJson(),
      'items': items.map((i) => i.toJson()).toList(),
      'date': date.toIso8601String(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'taxPercentage': taxPercentage,
      'taxAmount': taxAmount,
      'grandTotal': grandTotal,
      'amountPaid': amountPaid,
      'paymentStatus': paymentStatus,
      'paymentMode': paymentMode,
      'notes': notes,
      'pdfPath': pdfPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      customer: CustomerModel.fromJson(json['customer'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>)
          .map((item) => InvoiceItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      date: DateTime.parse(json['date'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      taxPercentage: (json['taxPercentage'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num).toDouble(),
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['paymentStatus'] as String? ?? 'Paid',
      paymentMode: json['paymentMode'] as String? ?? 'UPI / GPay',
      notes: json['notes'] as String? ?? '',
      pdfPath: json['pdfPath'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
