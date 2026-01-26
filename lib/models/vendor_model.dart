import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String userName;
  final String comment;
  final double stars;
  final DateTime timestamp;

  RatingModel({
    required this.userName,
    required this.comment,
    required this.stars,
    required this.timestamp,
  });

  factory RatingModel.fromMap(Map<String, dynamic> data) {
    return RatingModel(
      userName: data['userName'] ?? '',
      comment: data['comment'] ?? '',
      stars: (data['stars'] ?? 0.0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'comment': comment,
      'stars': stars,
      'timestamp': timestamp,
    };
  }
}

class ProductModel {
  final List<String> images;
  final String price;
  final String name;
  final int? capacity;
  final String? mobileNumber;
  final String? location;
  final String? priceType; // 'fixed', 'per_person'
  final String? categoryType; // 'car', 'catering', etc.
  final String? subType; // 'premium', 'buffet'
  final List<String> blockedDates;
  final List<String> bookedDates;
  final List<RatingModel> ratings;

  ProductModel({
    required this.images,
    required this.price,
    required this.name,
    this.capacity,
    this.mobileNumber,
    this.location,
    this.priceType,
    this.categoryType,
    this.subType,
    this.blockedDates = const [],
    this.bookedDates = const [],
    this.ratings = const [],
  });

  // Backward compatibility for single imageUrl
  String get imageUrl => images.isNotEmpty ? images.first : '';

  factory ProductModel.fromMap(Map<String, dynamic> data) {
    return ProductModel(
      images: List<String>.from(
        data['images'] ?? (data['imageUrl'] != null ? [data['imageUrl']] : []),
      ),
      price: data['price'] ?? '',
      name: data['name'] ?? '',
      capacity: data['capacity'],
      mobileNumber: data['mobileNumber'],
      location: data['location'],
      priceType: data['priceType'],
      categoryType: data['categoryType'],
      subType: data['subType'],
      blockedDates: List<String>.from(data['blockedDates'] ?? []),
      bookedDates: List<String>.from(data['bookedDates'] ?? []),
      ratings: (data['ratings'] as List? ?? [])
          .map((r) => RatingModel.fromMap(r as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'images': images,
      'imageUrl': imageUrl, // Keep for backward compatibility
      'price': price,
      'name': name,
      'capacity': capacity,
      'mobileNumber': mobileNumber,
      'location': location,
      'priceType': priceType,
      'categoryType': categoryType,
      'subType': subType,
      'blockedDates': blockedDates,
      'bookedDates': bookedDates,
      'ratings': ratings.map((r) => r.toMap()).toList(),
    };
  }

  double get averageRating {
    if (ratings.isEmpty) return 0.0;
    return ratings.map((r) => r.stars).reduce((a, b) => a + b) / ratings.length;
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
  final Map<String, String>
  availability; // {"YYYY-MM-DD": "available | blocked"}
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
    // Handle hybrid structure where Vendor IS the product (flattened)
    List<ProductModel> parsedProducts = (data['products'] as List? ?? [])
        .map((p) => ProductModel.fromMap(p as Map<String, dynamic>))
        .toList();

    // If no explicit products list, but top-level fields suggest a product-vendor, synthesize one.
    if (parsedProducts.isEmpty &&
        (data.containsKey('price') || data.containsKey('images'))) {
      // This handles the structure seen in user screenshot where price/images are at root
      // Inject serviceType as categoryType if missing so filtering works
      Map<String, dynamic> productData = Map.from(data);
      if (productData['categoryType'] == null) {
        productData['categoryType'] = data['serviceType'];
      }
      parsedProducts.add(ProductModel.fromMap(productData));
    }

    return VendorModel(
      vendorId: id,
      businessName:
          data['businessName'] ?? data['name'] ?? '', // Fallback to 'name'
      serviceType: data['serviceType'] ?? '',
      location: data['location'] ?? '',
      priceRange:
          data['priceRange'] ??
          data['price'] ??
          '', // Map direct price if needed
      description: data['description'] ?? '',
      contactNumber: data['contactNumber'] ?? data['mobileNumber'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      logoUrl:
          data['logoUrl'] ?? data['imageUrl'] ?? '', // Fallback to main image
      products: parsedProducts,
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

  double get averageRating {
    if (products.isEmpty) return 0.0;
    final allRatings = products.expand((p) => p.ratings).toList();
    if (allRatings.isEmpty) return 0.0;
    return allRatings.map((r) => r.stars).reduce((a, b) => a + b) /
        allRatings.length;
  }

  int get reviewCount {
    return products.fold(0, (sum, p) => sum + p.ratings.length);
  }
}
