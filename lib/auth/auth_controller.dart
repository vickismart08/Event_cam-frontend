import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../config/app_links.dart';
import 'host_user.dart';

final AuthController authController = AuthController();

class AuthController extends ChangeNotifier {
  User? _firebaseUser;

  User? get firebaseUser => _firebaseUser;

  HostUser? get host {
    final u = _firebaseUser;
    if (u == null || u.email == null) return null;
    return HostUser(email: u.email!, displayName: u.displayName);
  }

  void attachAuthListener() {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    FirebaseAuth.instance.authStateChanges().listen((User? u) {
      _firebaseUser = u;
      notifyListeners();
    });
  }

  Future<void> signInWithEmail({required String email, required String password}) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail({required String email, required String password}) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Sends Firebase’s password-reset email. No custom backend required.
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw FirebaseAuthException(code: 'invalid-email', message: 'Email is required.');
    }
    final loginUrl = '${AppLinks.baseUrl()}/login';
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: trimmed,
        actionCodeSettings: ActionCodeSettings(
          url: loginUrl,
          handleCodeInApp: false,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-continue-uri') {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: trimmed);
        return;
      }
      rethrow;
    }
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();
}
