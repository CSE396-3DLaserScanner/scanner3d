import 'package:flutter/material.dart';
import 'socket_service.dart'; // Make sure to import your SocketService file

enum HardwareStatus {
  scanning,
  scanningOtherDevice,
  idle,
}

class ScanProvider extends ChangeNotifier {
  void Function()? onScanCompleted;
  HardwareStatus _status = HardwareStatus.idle;
  HardwareStatus get status => _status;

  ScanProvider._private();
  static final ScanProvider _instance = ScanProvider._private();
  static ScanProvider get instance => _instance;

  void startScan() {
    _status = HardwareStatus.scanning;
    notifyListeners();
  }

  void cancelScan() {
    _status = HardwareStatus.idle;
    notifyListeners();
  }

  void finishScan() {
    if (onScanCompleted != null) {
      onScanCompleted!();
    }
    _status = HardwareStatus.idle;
    notifyListeners();
  }
}
