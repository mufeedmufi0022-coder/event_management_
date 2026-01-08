import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/vendor_model.dart';
import '../models/event_model.dart';
import '../models/booking_model.dart';
import '../models/log_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of counts (only active ones)
  Stream<Map<String, int>> getCounts() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      int users = snapshot.docs.where((d) => d['role'] == 'user' && (d.data()['isActive'] ?? true)).length;
      int vendors = snapshot.docs.where((d) => d['role'] == 'vendor' && (d.data()['isActive'] ?? true)).length;
      return {'users': users, 'vendors': vendors, 'events': 0}; // Events will be updated separately or in a combined stream
    });
  }

  // Stream of audit logs
  Stream<List<LogModel>> getLogs() {
    return _firestore
        .collection('logs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LogModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Soft delete any document
  Future<void> softDelete(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).update({'isActive': false});
    _logAction('system', 'Soft deleted $docId from $collection', 'admin');
  }

  // Manual Override for Bookings
  Future<void> manualOverrideBooking(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({'status': status});
    _logAction('system', 'Manual override status to $status for $bookingId', 'admin');
  }

  // Get all bookings for conflict detection visibility
  Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection('bookings')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Existing methods updated for stage-2
  Stream<List<UserModel>> getUsers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<UserModel>> getVendorUsers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'vendor')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<EventModel>> getEvents() {
    return _firestore
        .collection('events')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> updateStatus(String uid, String status) async {
    await _firestore.collection('users').doc(uid).update({'status': status});
    _logAction('system', 'Admin updated user $uid status to $status', 'admin');
  }

  Future<void> _logAction(String type, String action, String actorId) async {
    await _firestore.collection('logs').add({
      'type': type,
      'action': action,
      'actorId': actorId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
