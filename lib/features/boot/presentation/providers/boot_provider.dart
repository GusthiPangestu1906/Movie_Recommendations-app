import 'package:flutter/material.dart';

class BootProvider extends ChangeNotifier {
  double _progress = 0.0;
  String _status = "Initializing System...";

  double get progress => _progress;
  String get status => _status;

  final List<String> _logs = [
    "Loading Kernel...",
    "Initializing Firebase...",
    "Checking Network Connectivity...",
    "Syncing Remote Config...",
    "Optimizing Database...",
    "Mounting UI Modules...",
    "Starting NYXDEX Engine...",
    "Securing Connection...",
    "Ready to Launch",
  ];

  Future<void> runBootSequence(VoidCallback onComplete) async {
    _progress = 0.0;
    _status = _logs[0];
    notifyListeners();

    // Smooth cinematic boot sequence (~3.1s total duration for clear visual enjoyment)
    const int stepDelayMs = 300;
    for (int i = 0; i < _logs.length; i++) {
      _status = _logs[i];
      _progress = (i + 1) / _logs.length;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: stepDelayMs));
    }

    await Future.delayed(const Duration(milliseconds: 400));
    onComplete();
  }
}
