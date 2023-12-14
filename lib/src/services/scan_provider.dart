import 'package:flutter/material.dart';
import 'dart:async';

class ScanProvider extends ChangeNotifier {
  void Function()? onScanCompleted;
  bool _isScanning = false;
  int _totalTime = 5;
  int _remainingTime = 5;
  bool get isScanning => _isScanning;
  int get totalTime => _totalTime;
  int get remainingTime => _remainingTime;
  late Timer _timer;

  // Start the scan process
  void startScan() {
    _totalTime = 10;
    _remainingTime = _totalTime;
    _isScanning = true;
    notifyListeners();

    // Start a periodic timer to decrement remaining time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingTime--;

      // If the remaining time is less than or equal to 0, stop the timer and set isScanning to false
      if (_remainingTime <= 0) {
        timer.cancel();
        _isScanning = false;
        notifyListeners();

        // Call the onScanCompleted callback when scanning is completed
        if (onScanCompleted != null) {
          onScanCompleted!();
        }
      } else {
        notifyListeners();
      }
    });
  }

  // Cancel the scan process
  void cancelScan() {
    // Cancel the timer if it's active
    _timer.cancel();

    _isScanning = false;
    notifyListeners();
  }
}
