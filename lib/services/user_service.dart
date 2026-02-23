import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/booking_model.dart';
import '../models/vendor_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create an event
  Future<void> createEvent(EventModel event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  // Update event status
  Future<void> updateEventStatus(String eventId, String status) async {
    await _firestore.collection('events').doc(eventId).update({
      'status': status,
    });
    _logAction('event', 'Status updated to $status', eventId);
  }

  // Soft delete event
  Future<void> softDeleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).update({
      'isActive': false,
    });
    _logAction('event', 'Soft deleted event', eventId);
  }

  // Get user's events (only active ones)
  Stream<List<EventModel>> getMyEvents(String uid) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get all approved vendors (only active ones)
  Stream<List<VendorModel>> getApprovedVendors() {
    print('=== [DEBUG] FETCHING APPROVED VENDORS ===');
    return _firestore.collection('users').snapshots().map((snapshot) {
      final vendors = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              // Robust extraction
              final role = (data['role'] ?? '').toString().toLowerCase().trim();
              final status = (data['status'] ?? '')
                  .toString()
                  .toLowerCase()
                  .trim();
              final isActive =
                  (data['isActive'] ?? true).toString().toLowerCase() !=
                  'false';

              if (role != 'vendor') return null;

              // Security: Users only see approved and active vendors
              // Note: During testing, ensure you use Admin Dashboard to approve vendors
              if (status != 'approved' && status != 'active') {
                print(
                  'Skipping vendor ${doc.id} ("${data['businessName'] ?? data['name']}"): status="$status" is not "approved"',
                );
                return null;
              }

              if (!isActive) {
                print(
                  'Skipping vendor ${doc.id} ("${data['businessName'] ?? data['name']}"): isActive is false',
                );
                return null;
              }

              final vendor = VendorModel.fromMap(data, doc.id);
              print(
                '✓ VALID VENDOR LOADED: ${vendor.businessName} (${vendor.products.length} products)',
              );
              return vendor;
            } catch (e) {
              print('ERROR parsing vendor document ${doc.id}: $e');
              return null;
            }
          })
          .whereType<VendorModel>()
          .toList();
      print(
        '=== [DEBUG] TOTAL APPROVED VENDORS FOR USER: ${vendors.length} ===',
      );
      return vendors;
    });
  }

  // Send booking request
  Future<void> sendBookingRequest(BookingModel booking) async {
    // Check if vendor is available on requested date?
    // This will be enforced in UI mainly, but good to have here eventually.
    await _firestore.collection('bookings').add(booking.toMap());
    _logAction('booking', 'Request sent', booking.vendorId);
  }

  // Accept/Reject quotation
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
    });
    _logAction('booking', 'User updated status to $status', bookingId);
  }

  // Soft delete booking
  Future<void> softDeleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'isActive': false,
    });
  }

  // Get user's bookings
  Stream<List<BookingModel>> getMyBookings(String uid) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Submit feedback for a booking
  Future<void> submitFeedback(
    String bookingId,
    String vendorId,
    String productName,
    RatingModel rating,
  ) async {
    // 1. Update Vendor's Product Ratings
    final vendorDoc = await _firestore.collection('users').doc(vendorId).get();
    if (vendorDoc.exists) {
      final data = vendorDoc.data()!;
      List products = data['products'] ?? [];
      int index = products.indexWhere((p) => p['name'] == productName);

      if (index != -1) {
        List ratings = products[index]['ratings'] ?? [];
        ratings.add(rating.toMap());
        products[index]['ratings'] = ratings;

        await _firestore.collection('users').doc(vendorId).update({
          'products': products,
        });
      }
    }

    // 2. Mark Booking as having feedback
    await _firestore.collection('bookings').doc(bookingId).update({
      'hasFeedback': true,
    });
  }

  // Helper for audit logging (simplified for now)
  Future<void> _logAction(String type, String action, String actorId) async {
    await _firestore.collection('logs').add({
      'type': type,
      'action': action,
      'actorId': actorId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
