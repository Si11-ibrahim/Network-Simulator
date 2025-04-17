import 'dart:developer';

import 'package:flutter/material.dart';

class PingProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentPingData;
  bool _isAnimating = false;
  List<String> _currentPath = [];
  int _currentPathIndex = 0;

  Map<String, dynamic>? get currentPingData => _currentPingData;
  bool get isAnimating => _isAnimating;
  List<String> get currentPath => _currentPath;
  int get currentPathIndex => _currentPathIndex;

  void updatePingData(Map<String, dynamic> data) {
    log('PingProvider: Updating ping data: $data');
    _currentPingData = data;
    if (data['type'] == 'path_data' && data['path'] != null) {
      log('PingProvider: Setting up animation path: ${data['path']}');
      _currentPath = List<String>.from(data['path']);
      _currentPathIndex = 0;
      _isAnimating = true;
      log('PingProvider: Animation state - isAnimating: $_isAnimating, pathIndex: $_currentPathIndex, path: $_currentPath');
    } else {
      log('PingProvider: Received data is not path_data or path is null');
    }
    notifyListeners();
  }

  void updateAnimationProgress(int index) {
    log('PingProvider: Updating animation progress to index: $index');
    if (_isAnimating && index < _currentPath.length - 1) {
      _currentPathIndex = index;
      log('PingProvider: Animation progress updated - currentIndex: $_currentPathIndex');
      notifyListeners();
    } else {
      log('PingProvider: Animation progress update skipped - isAnimating: $_isAnimating, index: $index, pathLength: ${_currentPath.length}');
    }
  }

  void resetAnimation() {
    log('PingProvider: Resetting animation');
    _isAnimating = false;
    _currentPathIndex = 0;
    notifyListeners();
  }
}
