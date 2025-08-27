import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_check/states/app_state.dart';
import 'package:health_check/states/user_state.dart';
import 'package:provider/provider.dart';
import 'package:health_check/models/user.dart';

class UserService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  /// Google login
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Create GoogleSignIn instance
      final googleSignIn = GoogleSignIn().initialize();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Make sure tokens are not null
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;
      if (accessToken == null || idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google sign-in failed: missing token")),
        );
        return;
      }

      // Create Firebase credential
      final fb_auth.AuthCredential credential =
          fb_auth.GoogleAuthProvider.credential(
            accessToken: accessToken,
            idToken: idToken,
          );

      // Sign in with Firebase
      final fb_auth.UserCredential userCredential = await _auth
          .signInWithCredential(credential);
      final fb_auth.User? fbUser = userCredential.user;
      if (fbUser == null) return;

      // Create app User model
      final appUser = User(
        id: fbUser.uid,
        name: fbUser.displayName ?? 'No Name',
        email: fbUser.email ?? '',
        phoneNumber: fbUser.phoneNumber ?? '',
      );

      // Save user in state & Firestore
      await context.read<UserState>().setUser(appUser);

      // Update app flow
      context.read<AppState>().login();
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Google sign-in failed")));
    }
  }

  /// Instagram login placeholder
  Future<void> signInWithInstagram(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Instagram login not implemented yet")),
    );
  }

  /// Logout
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    context.read<UserState>().clearUser();
    context.read<AppState>().logout();
  }
}
