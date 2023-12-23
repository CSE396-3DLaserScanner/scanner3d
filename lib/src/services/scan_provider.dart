import 'package:flutter/material.dart';
import 'dart:async';

class ScanProvider extends ChangeNotifier {
  void Function()? onScanCompleted;
  bool _isScanning = false;
  int _totalTime = 0;
  int _remainingTime = 0;
  bool get isScanning => _isScanning;
  int get totalTime => _totalTime;
  int get remainingTime => _remainingTime;
  late Timer _timer;

  void startScan() {
    _totalTime = 2;
    _remainingTime = _totalTime;
    _isScanning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingTime--;

      if (_remainingTime <= 0) {
        timer.cancel();
        _isScanning = false;
        notifyListeners();

        if (onScanCompleted != null) {
          onScanCompleted!();
        }
      } else {
        notifyListeners();
      }
    });
  }

  void cancelScan() {
    _timer.cancel();

    _isScanning = false;
    notifyListeners();
  }
}
