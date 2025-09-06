import 'package:flutter/material.dart';
import 'package:health_check/services/user_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();
    String error = "";

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(error, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Sign in with Google"),
              onPressed: () async {
                final result = await userService.signInWithGoogle(context);
                if (result == "null") {
                  // error = result;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Google sign-in failed")),
                  );
                }
              },
            ),
            // const SizedBox(height: 16),
            // ElevatedButton.icon(
            //   icon: const Icon(Icons.camera_alt),
            //   label: const Text("Sign in with Instagram"),
            //   onPressed: () => {},
            //   // onPressed: () => userService.signInWithInstagram(context),
            // ),
          ],
        ),
      ),
    );
  }
}
