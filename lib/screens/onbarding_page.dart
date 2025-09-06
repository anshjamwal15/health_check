import 'package:flutter/material.dart';
import 'package:health_check/states/app_state.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: Build app tutorials carousel
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Center(
        child: Column(
          children: [
            Text('Onboarding Page'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.read<AppState>().completeOnboarding(),
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
