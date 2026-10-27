class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final String unit;
  final int usageCount;
  final DateTime createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.costPrice = 0.0,
    this.stockQuantity = 50,
    this.unit = 'pcs',
    this.usageCount = 0,
    required this.createdAt,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    double? costPrice,
    int? stockQuantity,
    String? unit,
    int? usageCount,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      'unit': unit,
      'usageCount': usageCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? 'General',
      price: (json['price'] as num).toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 50,
      unit: json['unit'] as String? ?? 'pcs',
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
