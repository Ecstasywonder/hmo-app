class ProviderModel {
  final String id;
  final String name;
  final String description;
  final String? logo;
  final String? website;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final double rating;
  final int reviewCount;
  final int subscriberCount;
  final int? yearEstablished;
  final String licenseNumber;
  final List<String> features;
  final Map<String, dynamic> coverage;
  final Map<String, dynamic> operatingHours;
  final Map<String, String> socialMedia;
  final List<Map<String, dynamic>> documents;
  final bool isVerified;
  final bool isActive;
  final DateTime? verifiedAt;
  final Map<String, dynamic> stats;

  ProviderModel({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    this.website,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.rating,
    required this.reviewCount,
    required this.subscriberCount,
    this.yearEstablished,
    required this.licenseNumber,
    required this.features,
    required this.coverage,
    required this.operatingHours,
    required this.socialMedia,
    required this.documents,
    required this.isVerified,
    required this.isActive,
    this.verifiedAt,
    required this.stats,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logo: json['logo'],
      website: json['website'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      subscriberCount: json['subscriberCount'] ?? 0,
      yearEstablished: json['yearEstablished'],
      licenseNumber: json['licenseNumber'],
      features: List<String>.from(json['features'] ?? []),
      coverage: json['coverage'] ?? {},
      operatingHours: json['operatingHours'] ?? {},
      socialMedia: Map<String, String>.from(json['socialMedia'] ?? {}),
      documents: List<Map<String, dynamic>>.from(json['documents'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      stats: json['stats'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'website': website,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'rating': rating,
      'reviewCount': reviewCount,
      'subscriberCount': subscriberCount,
      'yearEstablished': yearEstablished,
      'licenseNumber': licenseNumber,
      'features': features,
      'coverage': coverage,
      'operatingHours': operatingHours,
      'socialMedia': socialMedia,
      'documents': documents,
      'isVerified': isVerified,
      'isActive': isActive,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'stats': stats,
    };
  }
} 