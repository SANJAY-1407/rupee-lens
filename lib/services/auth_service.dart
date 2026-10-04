import 'package:firebase_auth/firebase_auth.dart';

import 'expense_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Load only this user's expenses into local Hive.
    await ExpenseService.switchUser();

    return credential;
  }

  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // New user gets only their own Firestore expenses.
    await ExpenseService.switchUser();

    return credential;
  }

  static Future<void> sendPasswordReset({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  static Future<void> signOut() async {
    // Clear current user's local data and Firestore listener first.
    await ExpenseService.clearUserSession();

    // Then sign out from Firebase.
    await _auth.signOut();
  }
}