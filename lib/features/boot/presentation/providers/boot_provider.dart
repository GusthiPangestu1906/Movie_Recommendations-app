import 'package:flutter/material.dart';

class BootProvider extends ChangeNotifier {
  double _progress = 0.0;
  String _statusMessage = "Starting...";

  double get progress => _progress;
  String get statusMessage => _statusMessage;

  final List<Map<String, dynamic>> _steps = [
    {"progress": 0.2, "message": "Starting..."},
    {"progress": 0.4, "message": "Loading..."},
    {"progress": 0.7, "message": "Syncing..."},
    {"progress": 1.0, "message": "Ready!"},
  ];

  Future<void> runBootSequence(VoidCallback onComplete) async {
    for (var step in _steps) {
      await Future.delayed(const Duration(milliseconds: 600));
      _progress = (step["progress"] as num).toDouble();
      _statusMessage = step["message"] as String;
      notifyListeners();
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    onComplete();
  }
}
