import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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

  Future<void> signOut() => FirebaseAuth.instance.signOut();
}
