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
    await _firestore.collection('events').doc(eventId).update({'status': status});
    _logAction('event', 'Status updated to $status', eventId);
  }

  // Soft delete event
  Future<void> softDeleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).update({'isActive': false});
    _logAction('event', 'Soft deleted event', eventId);
  }

  // Get user's events (only active ones)
  Stream<List<EventModel>> getMyEvents(String uid) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all approved vendors (only active ones)
  Stream<List<VendorModel>> getApprovedVendors() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'vendor')
        .where('status', isEqualTo: 'approved')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VendorModel.fromMap(doc.data(), doc.id))
            .toList());
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
    await _firestore.collection('bookings').doc(bookingId).update({'status': status});
    _logAction('booking', 'User updated status to $status', bookingId);
  }

  // Soft delete booking
  Future<void> softDeleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({'isActive': false});
  }

  // Get user's bookings
  Stream<List<BookingModel>> getMyBookings(String uid) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
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
