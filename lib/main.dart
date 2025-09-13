import 'package:flutter/material.dart';
import 'package:health_check/app.dart';
import 'package:health_check/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:health_check/states/app_state.dart';
import 'package:health_check/states/user_state.dart';
import 'package:health_check/states/schedule_state.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize app state and restore from storage
  final appState = AppState();
  final userState = UserState();
  final scheduleState = ScheduleState();
  
  // Initialize user state first to check if user exists
  await userState.initializeFromStorage();
  
  // Initialize app state from storage
  await appState.initializeFromStorage();
  
  // Initialize schedule state if user exists
  if (userState.user != null) {
    await scheduleState.initializeFromStorage(userState.user!.id);
  }
  
  // Set up callback for AppState to sync with Firebase through UserState
  appState.setStatusChangeCallback((AppStatus newStatus) async {
    await userState.updateAppStatus(newStatus);
  });
  
  // If user exists but app state is unknown/unauthenticated, set to authenticated
  if (userState.user != null && appState.status == AppStatus.unauthenticated) {
    await appState.setAuthenticated();
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: userState),
        ChangeNotifierProvider.value(value: scheduleState),
      ],
      child: const App(),
    ),
  );
}