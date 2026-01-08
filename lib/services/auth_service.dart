import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get user => _auth.authStateChanges();

  // Register with email and password
  Future<UserCredential?> registerWithEmail(String email, String password, String name, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      User? user = result.user;
      if (user != null) {
        // Create a new document for the user in firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': role,
          'status': role == 'vendor' ? 'pending' : 'approved',
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
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print('Login Error: ${e.code}');
      rethrow;
    } catch (e) {
      print('Login Error: $e');
      throw 'An unexpected error occurred during login';
    }
  }

  // Check if credentials match any document in 'admin' collection
  Future<bool> checkAdminCredentials(String email, String password) async {
    try {
      email = email.toLowerCase().trim();
      print('Checking admin credentials in Firestore for: $email');
      
      // Try exact email field search
      QuerySnapshot admin = await _firestore
          .collection('admin')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();
      
      if (admin.docs.isNotEmpty) {
        print('Admin found in admin collection (standard email field)');
        return true;
      }

      // Try checking if doc ID is email
      DocumentSnapshot adminDoc = await _firestore.collection('admin').doc(email).get();
      if (adminDoc.exists) {
        var data = adminDoc.data() as Map<String, dynamic>;
        if (data['password'] == password) {
          print('Admin found in admin collection (Doc ID is email)');
          return true;
        }
      }

      print('No matching admin found in admin collection');
      return false;
    } catch (e) {
      print('Admin Check Error: $e');
      return false;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      print('Fetching user data for UID: $uid');
      
      // 1. Check users collection
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        print('Found in users collection');
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
      }
      
      // 2. Backup check: Check admin collection
      User? currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email != null) {
        String email = currentUser.email!.toLowerCase().trim();
        print('Checking admin collection for email: $email');
        
        // Query by email field
        QuerySnapshot adminQuery = await _firestore
            .collection('admin')
            .where('email', isEqualTo: email)
            .get();
            
        if (adminQuery.docs.isNotEmpty) {
          print('Found in admin collection via email query');
          var data = adminQuery.docs.first.data() as Map<String, dynamic>;
          return UserModel(
            uid: uid,
            name: data['name'] ?? data['email'] ?? 'Admin',
            email: currentUser.email!,
            role: 'admin',
            status: 'approved',
          );
        }

        // Also check if document ID is the email (common manual pattern)
        DocumentSnapshot adminDoc = await _firestore.collection('admin').doc(email).get();
        if (adminDoc.exists) {
          print('Found in admin collection via doc ID (email)');
          var data = adminDoc.data() as Map<String, dynamic>;
          return UserModel(
            uid: uid,
            name: data['name'] ?? data['email'] ?? 'Admin',
            email: currentUser.email!,
            role: 'admin',
            status: 'approved',
          );
        }
      }
      
      print('User not found in users or admin collections');
      return null;
    } catch (e) {
      print('Get User Data Error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Initialize admin credentials in Firestore if they don't exist
  Future<void> initializeAdmin() async {
    try {
      final String adminEmail = 'admin@event.com';
      final String adminPassword = 'admin@123';
      
      DocumentSnapshot adminDoc = await _firestore.collection('admin').doc(adminEmail).get();
      
      if (!adminDoc.exists) {
        print('Initializing default admin in Firestore...');
        await _firestore.collection('admin').doc(adminEmail).set({
          'email': adminEmail,
          'password': adminPassword,
          'name': 'System Admin',
        });
        print('Admin initialization complete.');
      }
    } catch (e) {
      print('Error initializing admin: $e');
    }
  }
}
