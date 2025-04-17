import 'package:flutter/material.dart';

class ServerProvider with ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void updateConnection(bool status) {
    _isConnected = status;
    notifyListeners();
  }
}
