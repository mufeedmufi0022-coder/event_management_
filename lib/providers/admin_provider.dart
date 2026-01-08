import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/log_model.dart';
import '../models/booking_model.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  
  Map<String, int> _counts = {'users': 0, 'vendors': 0, 'events': 0};
  List<UserModel> _users = [];
  List<UserModel> _vendors = [];
  List<EventModel> _eventsList = [];
  List<LogModel> _logs = [];
  List<BookingModel> _allBookings = [];
  bool _isLoading = false;

  Map<String, int> get counts => _counts;
  List<UserModel> get users => _users;
  List<UserModel> get vendors => _vendors;
  List<EventModel> get eventsList => _eventsList;
  List<LogModel> get logs => _logs;
  List<BookingModel> get allBookings => _allBookings;
  bool get isLoading => _isLoading;

  AdminProvider() {
    _init();
  }

  void _init() {
    _adminService.getCounts().listen((data) {
      _counts = data;
      notifyListeners();
    });

    _adminService.getUsers().listen((data) {
      _users = data;
      notifyListeners();
    });

    _adminService.getVendorUsers().listen((data) {
      _vendors = data;
      notifyListeners();
    });

    _adminService.getEvents().listen((data) {
      _eventsList = data;
      notifyListeners();
    });

    _adminService.getLogs().listen((data) {
      _logs = data;
      notifyListeners();
    });

    _adminService.getAllBookings().listen((data) {
      _allBookings = data;
      notifyListeners();
    });
  }

  Future<void> updateStatus(String uid, String status) async {
    _setLoading(true);
    await _adminService.updateStatus(uid, status);
    _setLoading(false);
  }

  Future<void> softDelete(String collection, String docId) async {
    _setLoading(true);
    await _adminService.softDelete(collection, docId);
    _setLoading(false);
  }

  Future<void> manualOverrideBooking(String bookingId, String status) async {
    _setLoading(true);
    await _adminService.manualOverrideBooking(bookingId, status);
    _setLoading(false);
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
