import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../core/exceptions/app_exception.dart';

/// Firebase authentication data source
class FirebaseAuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  /// Login with email and password
  Future<firebase_auth.User> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException('Login failed: No user returned');
      }
      
      // Force reload user to ensure fresh data
      await credential.user!.reload();
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        throw AuthException('Login failed: User not found after reload');
      }
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on TypeError catch (e) {
      // Handle pigeon type casting errors
      throw AuthException('Authentication error: Please try again. ${e.toString()}');
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  /// Register with email and password
  Future<firebase_auth.User> register(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        throw AuthException('Registration failed: No user returned');
      }
      
      // Force reload user to ensure fresh data
      await credential.user!.reload();
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        throw AuthException('Registration failed: User not found after reload');
      }
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } on TypeError catch (e) {
      // Handle pigeon type casting errors
      throw AuthException('Authentication error: Please try again. ${e.toString()}');
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }
      
      if (user.emailVerified) {
        return; // Already verified
      }
      
      await user.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to send email verification: ${e.toString()}');
    }
  }

  /// Send phone verification OTP
  Future<void> sendPhoneVerification(
    String phoneNumber, {
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(firebase_auth.FirebaseAuthException error) verificationFailed,
    required void Function(firebase_auth.PhoneAuthCredential credential) verificationCompleted,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      throw AuthException('Failed to send phone verification: ${e.toString()}');
    }
  }

  /// Verify OTP code
  Future<bool> verifyOTP(String verificationId, String otp) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user logged in');
      }
      
      await user.linkWithCredential(credential);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('OTP verification failed: ${e.toString()}');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Logout failed: ${e.toString()}');
    }
  }

  /// Get current user
  firebase_auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Stream of authentication state changes
  Stream<firebase_auth.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  /// Map Firebase auth exceptions to domain exceptions
  AuthException _mapFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found with this email', e.code);
      case 'wrong-password':
        return AuthException('Incorrect password', e.code);
      case 'email-already-in-use':
        return AuthException('Email is already registered', e.code);
      case 'invalid-email':
        return AuthException('Invalid email address', e.code);
      case 'weak-password':
        return AuthException('Password is too weak', e.code);
      case 'user-disabled':
        return AuthException('This account has been disabled', e.code);
      case 'too-many-requests':
        return AuthException('Too many attempts. Please try again later', e.code);
      case 'operation-not-allowed':
        return AuthException('Operation not allowed', e.code);
      case 'invalid-verification-code':
        return AuthException('Invalid verification code', e.code);
      case 'invalid-verification-id':
        return AuthException('Invalid verification ID', e.code);
      case 'credential-already-in-use':
        return AuthException('This credential is already linked to another account', e.code);
      default:
        return AuthException(e.message ?? 'Authentication failed', e.code);
    }
  }
}
