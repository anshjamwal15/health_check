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
  Future<String> signInWithGoogle(BuildContext context) async {
    try {
      // 1⃣ Initialize GoogleSignIn with scopes (and optional clientId)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        // clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com', // optional, if needed
      );

      // 2⃣ Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return "null"; // User canceled sign-in

      // 3⃣ Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 4⃣ Create a credential for Firebase
      final fb_auth.AuthCredential credential =
          fb_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

      // 5⃣ Sign in to Firebase
      final fb_auth.UserCredential userCredential = await _auth
          .signInWithCredential(credential);
      final fb_auth.User? fbUser = userCredential.user;
      if (fbUser == null) return "null";

      // 6⃣ Map to your app’s user model
      final appUser = User(
        id: fbUser.uid,
        name: fbUser.displayName ?? 'No Name',
        email: fbUser.email ?? '',
        phoneNumber: fbUser.phoneNumber ?? '',
      );

      // 7⃣ Store user in state and update app state
      await context.read<UserState>().setUser(appUser);
      context.read<AppState>().login();
      return fbUser.uid;
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      return e.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Google sign-in failed")));
    }
  }

  /// Logout
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    await GoogleSignIn().signOut(); // Important: clear Google session too
    context.read<UserState>().clearUser();
    context.read<AppState>().logout();
  }

  /// Placeholder for Instagram
  Future<void> signInWithInstagram(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Instagram login not implemented yet")),
    );
  }
}
