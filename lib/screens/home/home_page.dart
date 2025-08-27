import 'package:flutter/material.dart';
import 'package:health_check/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:health_check/states/user_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;
    final userService = UserService();

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${user?.name ?? 'Guest'}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => userService.logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Email: ${user?.email ?? 'Not set'}"),
            Text("Phone: ${user?.phoneNumber ?? 'Not set'}"),
          ],
        ),
      ),
    );
  }
}
