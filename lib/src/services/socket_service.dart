import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;

class SocketService extends ChangeNotifier {
  late socket_io.Socket _socket;
  String _ipAddress = "127.0.0.1";
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  String get ipAddress => _ipAddress;

  // TODO: Setup communication
  void connectSocket(String ipAddress) {
    _isConnected = true;
    _ipAddress = ipAddress;
    notifyListeners();
    //_initSocket(ipAddress);
  }

  // ignore: unused_element
  void _initSocket(String ipAddress) {
    _socket = socket_io.io(ipAddress);

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

  // TODO: Setup communication
  void disconnectSocket() {
    // _socket.disconnect();
    _isConnected = false;
    notifyListeners();
  }
}
