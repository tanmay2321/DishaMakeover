class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double totalSpent;
  final int totalInvoices;
  final DateTime lastVisit;
  final String notes;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address = '',
    this.totalSpent = 0.0,
    this.totalInvoices = 0,
    required this.lastVisit,
    this.notes = '',
  });

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    double? totalSpent,
    int? totalInvoices,
    DateTime? lastVisit,
    String? notes,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      totalSpent: totalSpent ?? this.totalSpent,
      totalInvoices: totalInvoices ?? this.totalInvoices,
      lastVisit: lastVisit ?? this.lastVisit,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'totalSpent': totalSpent,
      'totalInvoices': totalInvoices,
      'lastVisit': lastVisit.toIso8601String(),
      'notes': notes,
    };
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      totalInvoices: (json['totalInvoices'] as num?)?.toInt() ?? 0,
      lastVisit: json['lastVisit'] != null
          ? DateTime.parse(json['lastVisit'] as String)
          : DateTime.now(),
      notes: json['notes'] as String? ?? '',
    );
  }
}
