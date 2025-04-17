import 'package:flutter/material.dart';
import 'package:network_simulator/Constants/Templates.dart';

class LoadingService {
  static final LoadingService _instance = LoadingService._internal();
  factory LoadingService() => _instance;
  LoadingService._internal();

  bool _isLoading = false;
  BuildContext? _context;

  void initialize(BuildContext context) {
    _context = context;
  }

  bool get isLoading => _isLoading;

  void showLoading() {
    if (_context != null && !_isLoading) {
      _isLoading = true;
      MyDialogs.loadingStart(_context!);
    }
  }

  void hideLoading() {
    if (_context != null && _isLoading) {
      _isLoading = false;
      Navigator.pop(_context!);
    }
  }

  void dispose() {
    if (_isLoading) {
      hideLoading();
    }
    _context = null;
  }
}
