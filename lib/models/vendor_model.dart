class ProductModel {
  final String imageUrl;
  final String price;
  final String name;

  ProductModel({
    required this.imageUrl,
    required this.price,
    required this.name,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data) {
    return ProductModel(
      imageUrl: data['imageUrl'] ?? '',
      price: data['price'] ?? '',
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'price': price,
      'name': name,
    };
  }
}

class VendorModel {
  final String vendorId;
  final String businessName;
  final String serviceType;
  final String location;
  final String priceRange;
  final String description;
  final String contactNumber;
  final List<String> images;
  final String logoUrl;
  final List<ProductModel> products;
  final String status; // 'pending', 'approved'
  final Map<String, String> availability; // {"YYYY-MM-DD": "available | blocked"}
  final bool isActive;

  VendorModel({
    required this.vendorId,
    required this.businessName,
    required this.serviceType,
    required this.location,
    required this.priceRange,
    required this.description,
    required this.contactNumber,
    required this.images,
    required this.logoUrl,
    required this.products,
    required this.status,
    this.availability = const {},
    this.isActive = true,
  });

  factory VendorModel.fromMap(Map<String, dynamic> data, String id) {
    return VendorModel(
      vendorId: id,
      businessName: data['businessName'] ?? '',
      serviceType: data['serviceType'] ?? '',
      location: data['location'] ?? '',
      priceRange: data['priceRange'] ?? '',
      description: data['description'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      logoUrl: data['logoUrl'] ?? '',
      products: (data['products'] as List? ?? [])
          .map((p) => ProductModel.fromMap(p as Map<String, dynamic>))
          .toList(),
      status: data['status'] ?? 'pending',
      availability: Map<String, String>.from(data['availability'] ?? {}),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'serviceType': serviceType,
      'location': location,
      'priceRange': priceRange,
      'description': description,
      'contactNumber': contactNumber,
      'images': images,
      'logoUrl': logoUrl,
      'products': products.map((p) => p.toMap()).toList(),
      'status': status,
      'availability': availability,
      'isActive': isActive,
    };
  }
}
