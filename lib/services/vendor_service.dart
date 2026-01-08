import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';
import '../models/booking_model.dart';

class VendorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get vendor profile
  Future<VendorModel?> getVendorProfile(String vendorId) async {
    final doc = await _firestore.collection('users').doc(vendorId).get();
    if (doc.exists && (doc.data() as Map<String, dynamic>).containsKey('businessName')) {
      return VendorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Update vendor profile
  Future<void> updateVendorProfile(VendorModel vendor) async {
    await _firestore.collection('users').doc(vendor.vendorId).update(vendor.toMap());
  }

  // Update availability
  Future<void> updateAvailability(String vendorId, Map<String, String> availability) async {
    await _firestore.collection('users').doc(vendorId).update({
      'availability': availability,
    });
    _logAction('vendor', 'Availability updated', vendorId);
  }

  // Get incoming booking requests
  Stream<List<BookingModel>> getBookingRequests(String vendorId) {
    return _firestore
        .collection('bookings')
        .where('vendorId', isEqualTo: vendorId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Send Quotation
  Future<void> sendQuotation(String bookingId, String price, String note) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'quoted',
      'quotePrice': price,
      'quoteNote': note,
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
    });
    _logAction('booking', 'Quotation sent: ₹$price', bookingId);
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({'status': status});
    _logAction('booking', 'Vendor updated status to $status', bookingId);
  }

  // Helper for audit logging
  Future<void> _logAction(String type, String action, String actorId) async {
    await _firestore.collection('logs').add({
      'type': type,
      'action': action,
      'actorId': actorId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
