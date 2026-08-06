import 'dart:math';
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

    final Random random = Random();

    for (int i = 0; i < _logs.length; i++) {
      // Update status text
      _status = _logs[i];
      notifyListeners();

      // Hitung target progress untuk log ini
      double targetProgress = (i + 1) / _logs.length;

      // Durasi bervariasi biar gak kaku
      int duration = 400 + random.nextInt(800);
      if (i == 4) duration = 1500; // Simulasi optimasi yang lama

      await _smoothProgress(_progress, targetProgress, duration);
      await Future.delayed(Duration(milliseconds: random.nextInt(200)));
    }

    await Future.delayed(const Duration(milliseconds: 800));
    onComplete();
  }

  Future<void> _smoothProgress(double start, double end, int durationMs) async {
    final int steps = 15;
    final int stepDuration = durationMs ~/ steps;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      _progress = start + (end - start) * (i / steps);
      notifyListeners();
    }
  }
}
