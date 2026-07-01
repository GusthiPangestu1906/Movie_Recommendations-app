import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityProvider() {
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // connectivity_plus 6.0.0+ returns a List
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkInitialConnection() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    _updateConnectionStatus(results);
  }

  Future<void> checkConnection() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool previousStatus = _isOnline;

    // Check if there's any active connection
    _isOnline = results.isNotEmpty &&
                !results.contains(ConnectivityResult.none);

    debugPrint('=== NETWORK STATUS: ${_isOnline ? "ONLINE" : "OFFLINE"} ===');
    debugPrint('Results: $results');

    if (previousStatus != _isOnline) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
