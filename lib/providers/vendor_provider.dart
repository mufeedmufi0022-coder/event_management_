import 'package:flutter/material.dart';
import '../services/vendor_service.dart';
import '../models/vendor_model.dart';
import '../models/booking_model.dart';

class VendorProvider extends ChangeNotifier {
  final VendorService _vendorService = VendorService();
  VendorModel? _vendorModel;
  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  VendorModel? get vendorModel => _vendorModel;
  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  void init(String vendorId) async {
    _vendorModel = await _vendorService.getVendorProfile(vendorId);
    notifyListeners();

    _vendorService.getBookingRequests(vendorId).listen((data) {
      _bookings = data;
      notifyListeners();
    });
  }

  Future<void> updateProfile(VendorModel vendor) async {
    _setLoading(true);
    try {
      await _vendorService.updateVendorProfile(vendor);
      _vendorModel = vendor;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('exceeds the maximum allowed size')) {
        print(
          'CRITICAL: Document exceeds 1MB Firestore limit. Image cleanup required.',
        );
        // We could potentially trigger a local cleanup here or just notify UI
        rethrow;
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAvailability(Map<String, String> availability) async {
    if (_vendorModel == null) return;
    _setLoading(true);
    await _vendorService.updateAvailability(
      _vendorModel!.vendorId,
      availability,
    );
    _vendorModel = await _vendorService.getVendorProfile(
      _vendorModel!.vendorId,
    );
    _setLoading(false);
  }

  Future<void> sendQuotation(
    String bookingId,
    String price,
    String note,
  ) async {
    _setLoading(true);
    await _vendorService.sendQuotation(bookingId, price, note);
    _setLoading(false);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    _setLoading(true);
    await _vendorService.updateBookingStatus(bookingId, status);
    _setLoading(false);
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
