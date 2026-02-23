import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get user => _auth.authStateChanges();

  // Register with email and password
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Create a new document for the user in firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': role,
          'status': role == 'vendor' ? 'pending' : 'approved',
          'password': password, // Store password in Firestore for bypass login
        });
      }
      return result;
    } on FirebaseAuthException catch (e) {
      print('Register Error: ${e.code}');
      rethrow;
    } catch (e) {
      print('Register Error: $e');
      throw 'An unexpected error occurred during registration';
    }
  }

  // Login with email and password
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Login Error: ${e.code}');
      rethrow;
    } catch (e) {
      print('Login Error: $e');
      throw 'An unexpected error occurred during login';
    }
  }

  // Check if credentials match any document in 'users' collection (Firestore-only login)
  Future<UserModel?> firestoreLogin(String email, String password) async {
    try {
      email = email.toLowerCase().trim();
      print('=== FIRESTORE LOGIN ATTEMPT ===');
      print('Email: $email');
      print('Password length: ${password.length}');

      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      print('Found ${query.docs.length} user(s) with email: $email');

      if (query.docs.isEmpty) {
        print('ERROR: No user found with this email');
        return null;
      }

      // Check each document for matching password
      for (var doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('Checking user: ${data['name']} (${data['role']})');
        print('Stored password: ${data['password']}');
        print('Status: ${data['status']}');

        if (data['password'] == password) {
          print('✓ Password match!');

          final user = UserModel.fromMap(data, doc.id);

          // Check if vendor is approved
          if (user.role == 'vendor' && user.status != 'approved') {
            print('WARNING: Vendor account is ${user.status}');
            throw 'Your vendor account is ${user.status}. Please wait for admin approval.';
          }

          print('✓ Login successful for ${user.role}');
          return user;
        } else {
          print('✗ Password mismatch');
        }
      }

      print('ERROR: Password did not match for any user with this email');
      return null;
    } catch (e) {
      print('FIRESTORE LOGIN ERROR: $e');
      rethrow;
    }
  }

  // Legacy check kept for compatibility
  Future<bool> checkAdminCredentials(String email, String password) async {
    UserModel? user = await firestoreLogin(email, password);
    return user != null && user.role == 'admin';
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      print('Fetching user data for UID: $uid');

      // 1. Check users collection
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        print('Found in users collection');
        return UserModel.fromMap(
          userDoc.data() as Map<String, dynamic>,
          userDoc.id,
        );
      }

      print('User not found in users collection');
      return null;
    } catch (e) {
      print('Get User Data Error: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
