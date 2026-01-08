import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Listen to auth state changes
    _authService.user.listen((User? user) async {
      if (user != null) {
        await _fetchUserData(user.uid);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    _isLoading = true;
    notifyListeners();
    _userModel = await _authService.getUserData(uid);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> register(String email, String password, String name, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      UserCredential? result = await _authService.registerWithEmail(email, password, name, role);
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
      UserCredential? result = await _authService.loginWithEmail(email, password);
      _isLoading = false;
      notifyListeners();
      return result != null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
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

  Future<bool> adminLogin(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // 1. Verify against Firestore 'admin' collection
      bool isAuthorized = await _authService.checkAdminCredentials(email, password);
      
      if (isAuthorized) {
        UserCredential? result;
        try {
          result = await _authService.loginWithEmail(email, password);
        } catch (e) {
          print('Admin verified but login failed, attempting auto-creation...');
          result = await _authService.registerWithEmail(email, password, 'System Admin', 'admin');
        }
        
        _isLoading = false;
        notifyListeners();
        return result != null;
      } else {
        _errorMessage = 'Invalid admin credentials';
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

  Future<void> logout() async {
    await _authService.signOut();
  }
}
