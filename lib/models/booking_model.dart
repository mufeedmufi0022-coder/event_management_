import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String? eventId; // Optional now
  final String vendorId;
  final String userId;
  final String status;
  final DateTime bookingDate; // Required for direct bookings
  final String? occasion; // e.g., Wedding, Birthday
  final DateTime? expiresAt;
  final String? quotePrice;
  final String? quoteNote;
  final String? productName;
  final String? productImage;
  final bool isActive;

  BookingModel({
    required this.bookingId,
    this.eventId,
    required this.vendorId,
    required this.userId,
    required this.status,
    required this.bookingDate,
    this.productName,
    this.productImage,
    this.occasion,
    this.expiresAt,
    this.quotePrice,
    this.quoteNote,
    this.isActive = true,
  });

  factory BookingModel.fromMap(Map<String, dynamic> data, String id) {
    return BookingModel(
      bookingId: id,
      eventId: data['eventId'],
      vendorId: data['vendorId'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'requested',
      bookingDate: (data['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      productName: data['productName'],
      productImage: data['productImage'],
      occasion: data['occasion'],
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      quotePrice: data['quotePrice'],
      quoteNote: data['quoteNote'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'vendorId': vendorId,
      'userId': userId,
      'status': status,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'productName': productName,
      'productImage': productImage,
      'occasion': occasion,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'quotePrice': quotePrice,
      'quoteNote': quoteNote,
      'isActive': isActive,
    };
  }
}
