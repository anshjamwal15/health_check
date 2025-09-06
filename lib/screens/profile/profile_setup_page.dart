import 'package:flutter/material.dart';
import 'package:health_check/states/app_state.dart';
import 'package:provider/provider.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profile Setup Page'),
            ElevatedButton(
              onPressed: () => context.read<AppState>().completeProfile(),
              child: Text('Complete Setup'),
            ),
          ],
        ),
      ),
    );
  }
}
