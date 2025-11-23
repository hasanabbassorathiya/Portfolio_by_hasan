import 'package:flutter/material.dart';

class AppLogger with ChangeNotifier {
  static final AppLogger logger = AppLogger._internal();
  List<String> logs = [];
  static AppLogger _internal() {
    debugPrint('AppLogger has been created');
    return logger;
  }

  void logMessage(String message) {
    DateTime now = DateTime.now();
    String logMessage = '[$now]:\t $message';
    debugPrint(logMessage);
    logs.add(logMessage);
    notifyListeners();
  }

  List<String> get allLogs {
    return logs;
  }
}
