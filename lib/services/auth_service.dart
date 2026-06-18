import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import './firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential?> signIn(
    String email,
    String password, {
    bool keepSignedIn = true,
  }) async {
    try {
      if (kIsWeb) {
        await _auth.setPersistence(
          keepSignedIn ? Persistence.LOCAL : Persistence.SESSION,
        );
      }
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('FIREBASE AUTH ERROR: ${e.code} - ${e.message}');
      throw _authErrorMessage(e.code);
    } catch (e) {
      if (kDebugMode) print('SIGN IN ERROR: $e');
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<UserCredential?> signUp(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null && name != null) {
        try {
          await credential.user!.updateDisplayName(name);
          await credential.user!.reload();

          final isSystemAdmin = email.trim().toLowerCase() == 'admin@travelagency.com';

          // Save basic user data to Firestore
          await _firestoreService.updateUserProfile(credential.user!.uid, {
            'displayName': name,
            'email': email,
            'role': isSystemAdmin ? 'admin' : 'user',
            'isAdmin': isSystemAdmin,
            'createdAt': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          if (kDebugMode) {
            print('FIRESTORE SAVE ERROR during registration: $e');
          }
        }
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FIREBASE REGISTRATION ERROR: ${e.code} - ${e.message}');
      }
      throw _authErrorMessage(e.code);
    } catch (e) {
      if (kDebugMode) print('GENERAL REGISTRATION ERROR: $e');
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('FIREBASE RESET ERROR: ${e.code} - ${e.message}');
      throw _authErrorMessage(e.code);
    } catch (e) {
      if (kDebugMode) print('GENERAL RESET ERROR: $e');
      throw 'Something went wrong. Please try again.';
    }
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'configuration-not-found':
        return 'Authentication is not configured. Please contact support.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
