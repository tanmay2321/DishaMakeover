class InvoiceItemModel {
  final String id;
  final String? productId;
  final String name;
  final String category;
  final double unitPrice;
  final int quantity;
  final double discount; // Flat ₹ discount on this line item

  const InvoiceItemModel({
    required this.id,
    this.productId,
    required this.name,
    this.category = 'General',
    required this.unitPrice,
    this.quantity = 1,
    this.discount = 0.0,
  });

  double get subtotal => unitPrice * quantity;
  double get total => (subtotal - discount) > 0 ? (subtotal - discount) : 0.0;

  InvoiceItemModel copyWith({
    String? id,
    String? productId,
    String? name,
    String? category,
    double? unitPrice,
    int? quantity,
    double? discount,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'category': category,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'discount': discount,
      'total': total,
    };
  }

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String?,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'General',
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
