import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, User?>((ref) {
  return AuthStateNotifier(FirebaseAuth.instance);
});

class AuthStateNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth;

  AuthStateNotifier(this._auth) : super(_auth.currentUser) {
    _auth.authStateChanges().listen((user) {
      state = user;
    });
  }

  Future<void> signInWithToken(String token) async {
    await _auth.signInWithCustomToken(token);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
