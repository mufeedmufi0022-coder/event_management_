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
  String? _error;

  List<EventModel> get myEvents => _myEvents;
  List<BookingModel> get myBookings => _myBookings;
  List<VendorModel> get approvedVendors => _approvedVendors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void init(String uid) {
    _userService
        .getMyEvents(uid)
        .listen(
          (data) {
            _myEvents = data;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            print('ERROR loading events: $e');
            _error = 'Failed to load events: $e';
            notifyListeners();
          },
        );

    _userService
        .getMyBookings(uid)
        .listen(
          (data) {
            _myBookings = data;
            _error = null;
            notifyListeners();
          },
          onError: (e) {
            print('ERROR loading bookings: $e');
            _error = 'Failed to load bookings: $e';
            notifyListeners();
          },
        );

    _userService.getApprovedVendors().listen(
      (data) {
        print('SUCCESS: Loaded ${data.length} approved vendors');
        _approvedVendors = data;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        print('ERROR loading vendors: $e');
        _error = 'Failed to load vendors: $e';
        _approvedVendors = [];
        notifyListeners();
      },
    );
  }

  Future<void> createEvent(EventModel event) async {
    _setLoading(true);
    try {
      await _userService.createEvent(event);
      _error = null;
    } catch (e) {
      print('ERROR creating event: $e');
      _error = 'Failed to create event: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEventStatus(String eventId, String status) async {
    _setLoading(true);
    try {
      await _userService.updateEventStatus(eventId, status);
      _error = null;
    } catch (e) {
      print('ERROR updating event status: $e');
      _error = 'Failed to update event: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> softDeleteEvent(String eventId) async {
    _setLoading(true);
    try {
      await _userService.softDeleteEvent(eventId);
      _error = null;
    } catch (e) {
      print('ERROR deleting event: $e');
      _error = 'Failed to delete event: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendBookingRequest(BookingModel booking) async {
    _setLoading(true);
    try {
      await _userService.sendBookingRequest(booking);
      _error = null;
    } catch (e) {
      print('ERROR sending booking: $e');
      _error = 'Failed to send booking: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    _setLoading(true);
    try {
      await _userService.updateBookingStatus(bookingId, status);
      _error = null;
    } catch (e) {
      print('ERROR updating booking: $e');
      _error = 'Failed to update booking: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> softDeleteBooking(String bookingId) async {
    _setLoading(true);
    try {
      await _userService.softDeleteBooking(bookingId);
      _error = null;
    } catch (e) {
      print('ERROR deleting booking: $e');
      _error = 'Failed to delete booking: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
