import 'package:flutter/material.dart';
import 'package:health_check/app.dart';
import 'package:health_check/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:health_check/states/app_state.dart';
import 'package:health_check/states/user_state.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => UserState()),
      ],
      child: const App(),
    ),
  );
}
