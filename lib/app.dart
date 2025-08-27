import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:health_check/screens/auth/login_page.dart';
import 'package:health_check/screens/home/home_page.dart';
import 'package:health_check/states/app_state.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  List<Page> onGeneratePages(AppStatus status, List<Page> pages) {
    switch (status) {
      case AppStatus.authenticated:
        return [const MaterialPage(child: HomePage())];
      case AppStatus.unauthenticated:
        return [const MaterialPage(child: LoginPage())];
      default:
        return [
          const MaterialPage(
            child: Scaffold(body: Center(child: CircularProgressIndicator())),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlowBuilder<AppStatus>(
        state: appState.status,
        onGeneratePages: onGeneratePages,
      ),
    );
  }
}
