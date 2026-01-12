import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../models/event_model.dart';
import '../models/vendor_model.dart';
import '../models/booking_model.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  List<EventModel> _myEvents = [];
  List<BookingModel> _myBookings = [];
  List<VendorModel> _approvedVendors = [];
  bool _isLoading = false;

  List<EventModel> get myEvents => _myEvents;
  List<BookingModel> get myBookings => _myBookings;
  List<VendorModel> get approvedVendors => _approvedVendors;
  bool get isLoading => _isLoading;

  void init(String uid) {
    _userService.getMyEvents(uid).listen((data) {
      _myEvents = data;
      notifyListeners();
    });

    _userService.getMyBookings(uid).listen((data) {
      _myBookings = data;
      notifyListeners();
    });

    _userService.getApprovedVendors().listen((data) {
      _approvedVendors = data;
      notifyListeners();
    });
  }

  Future<void> createEvent(EventModel event) async {
    _setLoading(true);
    await _userService.createEvent(event);
    _setLoading(false);
  }

  Future<void> updateEventStatus(String eventId, String status) async {
    _setLoading(true);
    await _userService.updateEventStatus(eventId, status);
    _setLoading(false);
  }

  Future<void> softDeleteEvent(String eventId) async {
    _setLoading(true);
    await _userService.softDeleteEvent(eventId);
    _setLoading(false);
  }

  Future<void> sendBookingRequest(BookingModel booking) async {
    _setLoading(true);
    await _userService.sendBookingRequest(booking);
    _setLoading(false);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    _setLoading(true);
    await _userService.updateBookingStatus(bookingId, status);
    _setLoading(false);
  }

  Future<void> softDeleteBooking(String bookingId) async {
    _setLoading(true);
    await _userService.softDeleteBooking(bookingId);
    _setLoading(false);
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
