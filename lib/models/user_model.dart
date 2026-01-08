class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'user', 'vendor', 'admin'
  final String status; // 'pending', 'approved', 'blocked'

  // Vendor specific fields (Optional)
  final String? businessName;
  final String? serviceType;
  final String? location;
  final String? priceRange;
  final String? description;
  final String? contactNumber;
  final List<String> images;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.businessName,
    this.serviceType,
    this.location,
    this.priceRange,
    this.description,
    this.contactNumber,
    this.images = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      status: data['status'] ?? 'pending',
      businessName: data['businessName'],
      serviceType: data['serviceType'],
      location: data['location'],
      priceRange: data['priceRange'],
      description: data['description'],
      contactNumber: data['contactNumber'],
      images: List<String>.from(data['images'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'businessName': businessName,
      'serviceType': serviceType,
      'location': location,
      'priceRange': priceRange,
      'description': description,
      'contactNumber': contactNumber,
      'images': images,
    };
  }
}
