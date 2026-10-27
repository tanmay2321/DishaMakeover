class BusinessProfileModel {
  final String businessName;
  final String ownerName;
  final String phone;
  final String tagline;
  final String address;
  final String upiId;
  final String gstin;
  final String termsAndConditions;

  const BusinessProfileModel({
    this.businessName = 'Disha Makeover',
    this.ownerName = 'Prof. Tejal Patel',
    this.phone = '+91 9428195591',
    this.tagline = 'Beauty Brings Out the Best in You',
    this.address = 'Disha Makeover Studio, Anand, Gujarat',
    this.upiId = '9428195591@okaxis',
    this.gstin = '',
    this.termsAndConditions =
        '1. Products once sold are non-refundable.\n2. Genuine salon-grade products guaranteed.\n3. Beauty Brings Out the Best in You!',
  });

  BusinessProfileModel copyWith({
    String? businessName,
    String? ownerName,
    String? phone,
    String? tagline,
    String? address,
    String? upiId,
    String? gstin,
    String? termsAndConditions,
  }) {
    return BusinessProfileModel(
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      tagline: tagline ?? this.tagline,
      address: address ?? this.address,
      upiId: upiId ?? this.upiId,
      gstin: gstin ?? this.gstin,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'ownerName': ownerName,
      'phone': phone,
      'tagline': tagline,
      'address': address,
      'upiId': upiId,
      'gstin': gstin,
      'termsAndConditions': termsAndConditions,
    };
  }

  factory BusinessProfileModel.fromJson(Map<String, dynamic> json) {
    return BusinessProfileModel(
      businessName: json['businessName'] as String? ?? 'Disha Makeover',
      ownerName: json['ownerName'] as String? ?? 'Prof. Tejal Patel',
      phone: json['phone'] as String? ?? '+91 9428195591',
      tagline: json['tagline'] as String? ?? 'Beauty Brings Out the Best in You',
      address: json['address'] as String? ?? 'Disha Makeover Studio, Anand, Gujarat',
      upiId: json['upiId'] as String? ?? '9428195591@okaxis',
      gstin: json['gstin'] as String? ?? '',
      termsAndConditions: json['termsAndConditions'] as String? ??
          '1. Products once sold are non-refundable.\n2. Genuine salon-grade products guaranteed.\n3. Beauty Brings Out the Best in You!',
    );
  }
}
