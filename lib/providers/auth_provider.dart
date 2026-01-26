import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/location_helper.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _userModel != null;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String? savedUid = prefs.getString('user_id');

    if (savedUid != null) {
      await _fetchUserData(savedUid);
    }

    // Listen to Firebase auth state changes as well
    _authService.user.listen((User? user) async {
      if (user != null && _userModel == null) {
        await _fetchUserData(user.uid);
      }
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchUserData(String uid) async {
    _isLoading = true;
    notifyListeners();
    _userModel = await _authService.getUserData(uid);
    // Background location update
    if (_userModel != null) {
      updateLocation();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register(
    String email,
    String password,
    String name,
    String role,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserCredential? result = await _authService.registerWithEmail(
        email,
        password,
        name,
        role,
      );
      if (result?.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', result!.user!.uid);
      }
      _isLoading = false;
      notifyListeners();
      return result != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Registration failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      print('=== LOGIN ATTEMPT ===');
      print('Email: $email');

      // Priority: Try Firestore manual login first to bypass security issues/reCAPTCHA
      UserModel? user = await _authService.firestoreLogin(email, password);
      if (user != null) {
        _userModel = user;

        // Save to local storage for persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.uid);

        // Background sync: Try logging into Firebase Auth quietly if possible
        try {
          await _authService.loginWithEmail(email, password);
          print('Firebase Auth sync successful');
        } catch (e) {
          print(
            'Background Firebase Auth login failed, continuing with Firestore session: $e',
          );
        }

        _isLoading = false;
        notifyListeners();
        print('✓ Login successful');
        return true;
      }

      _errorMessage = 'Invalid email or password';
      print('✗ Login failed: $_errorMessage');
      _isLoading = false;
      notifyListeners();
      return false;
    } on String catch (e) {
      // Catch custom error messages (like vendor approval status)
      _errorMessage = e;
      print('✗ Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      print('✗ Login exception: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> adminLogin(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserModel? user = await _authService.firestoreLogin(email, password);

      if (user != null && user.role == 'admin') {
        _userModel = user;

        // Save for persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.uid);

        // Background sync
        try {
          await _authService.loginWithEmail(email, password);
        } catch (e) {
          print('Admin background login failed, staying on Firestore session');
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid admin credentials or unauthorized';
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String photoUrl,
  }) async {
    if (_userModel == null) return;
    await _authService.updateProfile(_userModel!.uid, {
      'name': name,
      'contactNumber': phone,
      'logoUrl': photoUrl,
    });
    _userModel = await _authService.getUserData(_userModel!.uid);
    notifyListeners();
  }

  Future<void> setCustomLocation(String address, double lat, double lng) async {
    if (_userModel == null) return;
    try {
      // Clean up address if it contains full details, maybe shorter for display?
      // For now keep as is.
      await _authService.updateProfile(_userModel!.uid, {
        'currentAddress': address,
        'latitude': lat,
        'longitude': lng,
      });

      // Update local model
      _userModel = await _authService.getUserData(_userModel!.uid);
      notifyListeners();
    } catch (e) {
      print("Failed to set custom location: $e");
    }
  }

  Future<void> updateLocation() async {
    if (_userModel == null) return;

    try {
      final position = await LocationHelper.getCurrentPosition();
      if (position != null) {
        final address = await LocationHelper.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );

        // Use coordinates if address derivation fails
        final finalAddress =
            address ??
            "Lat: ${position.latitude.toStringAsFixed(2)}, Long: ${position.longitude.toStringAsFixed(2)}";

        await _authService.updateProfile(_userModel!.uid, {
          'currentAddress': finalAddress,
          'latitude': position.latitude,
          'longitude': position.longitude,
        });

        // Update local model
        _userModel = await _authService.getUserData(_userModel!.uid);
      } else {
        // If location is not available and we don't have an address yet, set a placeholder locally
        // This prevents the UI from being stuck on "Locating..."
        if (_userModel!.currentAddress == null ||
            _userModel!.currentAddress!.isEmpty) {
          // We create a temporary copy with a placeholder address just for the UI
          // We don't save this to the backend
          _userModel = _userModel!.copyWith(
            currentAddress: 'Location Unavailable',
          );
        }
      }
      notifyListeners();
    } catch (e) {
      print("Failed to update location: $e");
      // On error, also ensure we don't get stuck if address is null
      if (_userModel != null &&
          (_userModel!.currentAddress == null ||
              _userModel!.currentAddress!.isEmpty)) {
        _userModel = _userModel!.copyWith(
          currentAddress: 'Location Unavailable',
        );
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    _userModel = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await _authService.signOut();
    notifyListeners();
  }
}
