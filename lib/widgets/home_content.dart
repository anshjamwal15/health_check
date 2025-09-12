import 'package:flutter/material.dart';
import 'package:health_check/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:health_check/states/user_state.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserState>().user;
    final userService = UserService();
    
    return Scaffold(
      appBar: AppBar(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user?.photoUrl ?? ''),
        ),
        title: Text("Welcome ${user?.name ?? 'Guest'}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => userService.logout(context),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Hey, ${user?.name ?? ''}"),
          ],
        ),
      ),
    );
  }
}
