import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  late IO.Socket _socket;
  String _ipAddress = "";
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  String get ipAddress => _ipAddress;

  void connectSocket(String ipAddress) {
    _isConnected = true;
    _ipAddress = ipAddress;
    notifyListeners();
    //_initSocket(ipAddress);
  }

  void _initSocket(String ipAddress) {
    _socket = IO.io(ipAddress);

    _socket.onConnect((_) {
      _isConnected = true;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
      notifyListeners();
    });

    _socket.connect();
  }

  void disconnectSocket() {
    // _socket.disconnect();
    _isConnected = false;
    notifyListeners();
  }
}
