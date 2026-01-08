import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String eventId;
  final String vendorId;
  final String userId;
  final String status; // 'requested', 'quoted', 'accepted', 'completed', 'cancelled'
  final DateTime? expiresAt;
  final String? quotePrice;
  final String? quoteNote;
  final bool isActive;

  BookingModel({
    required this.bookingId,
    required this.eventId,
    required this.vendorId,
    required this.userId,
    required this.status,
    this.expiresAt,
    this.quotePrice,
    this.quoteNote,
    this.isActive = true,
  });

  factory BookingModel.fromMap(Map<String, dynamic> data, String id) {
    return BookingModel(
      bookingId: id,
      eventId: data['eventId'] ?? '',
      vendorId: data['vendorId'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? 'requested',
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
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'quotePrice': quotePrice,
      'quoteNote': quoteNote,
      'isActive': isActive,
    };
  }
}
