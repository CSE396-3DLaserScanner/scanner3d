import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  late IO.Socket _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connectSocket(String ipAddress, String port) {
    _isConnected = true;
    notifyListeners();
    //_initSocket(ipAddress, port);
  }

  void _initSocket(String ipAddress, String port) {
    _socket = IO.io('http://$ipAddress:$port', <String, dynamic>{
      'transports': ['websocket'],
    });

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
    _isConnected = false;
    notifyListeners();
    //_socket.disconnect();
  }
}
