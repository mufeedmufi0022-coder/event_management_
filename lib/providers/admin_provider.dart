import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/log_model.dart';
import '../models/booking_model.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  
  Map<String, int> _counts = {'users': 0, 'vendors': 0, 'events': 0};
  List<UserModel> _allUsers = [];
  List<UserModel> _users = [];
  List<UserModel> _vendors = [];
  List<EventModel> _eventsList = [];
  List<LogModel> _logs = [];
  List<BookingModel> _allBookings = [];
  bool _isLoading = false;

  Map<String, int> get counts => _counts;
  List<UserModel> get allUsers => _allUsers;
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
    // Listen to the unified user data stream
    _adminService.getAdminDataStream().listen((data) {
      _allUsers = data['allUsers'] as List<UserModel>;
      _counts = Map<String, int>.from(data['counts']);
      
      // Update specific lists
      _users = _allUsers.where((u) => u.role == 'user').toList();
      _vendors = _allUsers.where((u) => u.role == 'vendor').toList();
      
      print('AdminProvider: Processed ${_allUsers.length} total docs. Users: ${_users.length}, Vendors: ${_vendors.length}');
      notifyListeners();
    }, onError: (e) {
      print('AdminProvider Stream Error: $e');
    });

    // Listen for events (separate collection)
    _adminService.getEvents().listen((data) {
      _eventsList = data;
      notifyListeners();
    });

    // Listen for logs
    _adminService.getLogs().listen((data) {
      _logs = data;
      notifyListeners();
    });

    // Listen for bookings
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
