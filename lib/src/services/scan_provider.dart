import 'package:flutter/material.dart';

class ScanProvider extends ChangeNotifier {
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  // Start the scan process
  void startScan() {
    _isScanning = true;
    notifyListeners();

    // Simulate a scan process that takes 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      // Set isScanning to false after the scan is complete
      _isScanning = false;
      notifyListeners();
    });
  }

  // Cancel the scan process
  void cancelScan() {
    _isScanning = false;
    notifyListeners();
  }
}
