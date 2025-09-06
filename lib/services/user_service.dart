import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'package:health_check/states/user_state.dart';
import 'package:health_check/models/user.dart' as custom;

class UserService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  /// Google login
  Future<fb_auth.User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Firebase credential from Google auth
      final fb_auth.AuthCredential credential =
      fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final fb_auth.UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final fb_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Create app user model
        final custom.User appUser = custom.User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          phoneNumber: firebaseUser.photoURL ?? '',
        );

        // Update states
        Provider.of<UserState>(context, listen: false).setUser(appUser);
        // Provider.of<AppState>(context, listen: false).setLoggedIn(true);
      }

      return firebaseUser;
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      return null;
    }
  }

  /// General logout (only Google supported for now)
  Future<void> logout(BuildContext context) async {
    try {
      final fb_auth.User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        for (final provider in currentUser.providerData) {
          if (provider.providerId == 'google.com') {
            await GoogleSignIn().signOut();
          }
        }
      }

      await _auth.signOut();

      // Clear states
      Provider.of<UserState>(context, listen: false).clearUser();
      // Provider.of<AppState>(context, listen: false).setLoggedIn(false);
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }
}
