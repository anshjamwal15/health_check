import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_check/states/app_state.dart';
import 'package:provider/provider.dart';

import 'package:health_check/states/user_state.dart';
import 'package:health_check/models/user.dart' as custom;

class UserService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  /// Google login
  Future<custom.User?> signInWithGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn();

      // 🔹 Get providers before await
      final appState = context.read<AppState>();
      final userState = context.read<UserState>();

      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      // Get authentication tokens
      final googleAuth = await googleUser.authentication;

      // Firebase credential from Google auth
      final fb_auth.AuthCredential credential =
          fb_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Create app user model
        final custom.User appUser = custom.User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL ?? '',
          appStatus: appState.status,
        );

        // 🔹 Update states safely
        userState.setUser(appUser);
        appState.login();

        return appUser;
      }
    } catch (e, st) {
      debugPrint("Google sign-in error: $e\n$st");
      return null;
    }
    return null;
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
