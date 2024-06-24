import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:portfolio_app/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final AuthService _authService = AuthService._internal();

  AuthService._internal();

  final _firebaseAuth = FirebaseAuth.instance;

  factory AuthService() {
    return _authService;
  }

  User currentUser() {
    return _firebaseAuth.currentUser!;
  }

  Stream<User?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map((event) => event);
  }

  Future<void> signOutUser(BuildContext context) async {
    _firebaseAuth.signOut();
    Navigator.pushNamed(context, '/intro');
  }

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await _firebaseAuth.signInWithCredential(credential);
      if (authResult.user != null) {
        UserData user = UserData(
          uid: authResult.user!.uid,
          displayName: googleUser.displayName!,
        );
        await updateUser(user);
        return authResult.user!;
      }
      return authResult.user!;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(UserData user) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentSnapshot userInfoSnap = await docRef.get();
    if (userInfoSnap.exists) {
      return null;
    }
    return docRef.set(user.toJson(), SetOptions(merge: true));
  }
}
