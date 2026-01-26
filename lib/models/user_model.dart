import 'vendor_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'user', 'vendor', 'admin'
  final String status; // 'pending', 'approved', 'blocked'
  final bool isActive;

  // Vendor specific fields (Optional)
  final String? businessName;
  final String? location;
  final String? priceRange;
  final String? description;
  final String? contactNumber;
  final List<String> images;
  final String? logoUrl;
  final List<ProductModel> products;
  final String? currentAddress;
  final double? latitude;
  final double? longitude;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.isActive = true,
    this.businessName,
    this.location,
    this.priceRange,
    this.description,
    this.contactNumber,
    this.images = const [],
    this.logoUrl,
    this.products = const [],
    this.currentAddress,
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      role:
          data['role']?.toString().toLowerCase().trim() ??
          (data['businessName'] != null ? 'vendor' : 'user'),
      status: data['status']?.toString().toLowerCase().trim() ?? 'pending',
      isActive: data['isActive'] ?? true,
      businessName: data['businessName']?.toString(),
      location: data['location']?.toString(),
      priceRange: data['priceRange']?.toString(),
      description: data['description']?.toString(),
      contactNumber: data['contactNumber']?.toString(),
      images: data['images'] is List ? List<String>.from(data['images']) : [],
      logoUrl: data['logoUrl']?.toString(),
      products: data['products'] is List
          ? (data['products'] as List)
                .where((p) => p is Map)
                .map((p) => ProductModel.fromMap(Map<String, dynamic>.from(p)))
                .toList()
          : [],
      currentAddress: data['currentAddress']?.toString(),
      latitude: data['latitude'] != null
          ? (data['latitude'] as num).toDouble()
          : null,
      longitude: data['longitude'] != null
          ? (data['longitude'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'isActive': isActive,
      'businessName': businessName,
      'location': location,
      'priceRange': priceRange,
      'description': description,
      'contactNumber': contactNumber,
      'images': images,
      'logoUrl': logoUrl,
      'products': products.map((p) => p.toMap()).toList(),
      'currentAddress': currentAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? status,
    bool? isActive,
    String? businessName,
    String? location,
    String? priceRange,
    String? description,
    String? contactNumber,
    List<String>? images,
    String? logoUrl,
    List<ProductModel>? products,
    String? currentAddress,
    double? latitude,
    double? longitude,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      businessName: businessName ?? this.businessName,
      location: location ?? this.location,
      priceRange: priceRange ?? this.priceRange,
      description: description ?? this.description,
      contactNumber: contactNumber ?? this.contactNumber,
      images: images ?? this.images,
      logoUrl: logoUrl ?? this.logoUrl,
      products: products ?? this.products,
      currentAddress: currentAddress ?? this.currentAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
