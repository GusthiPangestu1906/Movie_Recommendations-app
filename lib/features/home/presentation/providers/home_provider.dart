import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  int _currentIndex = 0;
  bool _isDramaMode = false;

  int get currentIndex => _currentIndex;
  bool get isDramaMode => _isDramaMode;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleDramaMode() {
    _isDramaMode = !_isDramaMode;
    notifyListeners();
  }

  void setDramaMode(bool value) {
    _isDramaMode = value;
    notifyListeners();
  }
}
