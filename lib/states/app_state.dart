import 'package:flutter/foundation.dart';

enum AppStatus { unknown, unauthenticated, authenticated }

class AppState extends ChangeNotifier {
  AppStatus _status = AppStatus.unauthenticated;

  AppStatus get status => _status;

  void login() {
    _status = AppStatus.authenticated;
    notifyListeners();
  }

  void logout() {
    _status = AppStatus.unauthenticated;
    notifyListeners();
  }
}
