import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:Scanner3D/main.dart';
import 'package:Scanner3D/src/services/scan_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SocketService extends ChangeNotifier {
  late Socket _serverSocket;
  late Socket _configSocket;
  late Socket _broadcastSocket;
  late Socket _imageSocket;
  late Socket _liveSocket;

  String _ipAddress = "127.0.0.1";
  String get ipAddress => _ipAddress;

  final int _serverPort = 3000;
  final int _configPort = 3001;
  final int _broadcastPort = 3002;
  final int _imagePort = 3003;
  final int _livePort = 3004;

  int _fileSize = 0;
  StringBuffer stringBuffer = StringBuffer();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isReceived = false;
  bool get isReceived => _isReceived;

  SocketService._private();
  static final SocketService _instance = SocketService._private();
  static SocketService get instance => _instance;

  int _currentRound = 0;
  int _totalRound = 0;

  int get currentRound => _currentRound;
  int get totalRound => _totalRound;

  void connectSocket(String ipAddress) async {
    bool flag = true;
    _ipAddress = ipAddress;

    try {
      _serverSocket = await Socket.connect(_ipAddress, _serverPort);

      _serverSocket.listen(
        (List<int> data) {
          String receivedData = utf8.decode(data);

          developer.log('Server socket received data: $receivedData');
        },
        onDone: () {
          disconnectSockets();
          _isConnected = false;
          notifyListeners();

          developer.log('Server socket closed');
        },
        onError: (error) {
          developer.log('Server socket error: $error');
        },
      );
    } catch (e) {
      flag = false;
      developer.log("Error initializing server socket: $e");
    }

    if (flag) {
      try {
        _configSocket = await Socket.connect(_ipAddress, _configPort);

        _configSocket.listen(
          (List<int> data) {
            String receivedData = utf8.decode(data);

            developer.log('Config socket received data: $receivedData');
          },
          onDone: () {
            disconnectSockets();
            _isConnected = false;
            notifyListeners();

            developer.log('Config socket closed');
          },
          onError: (error) {
            developer.log('Config socket error: $error');
          },
        );
      } catch (e) {
        flag = false;
        developer.log("Error initializing config socket: $e");
      }
    }

    if (flag) {
      try {
        _broadcastSocket = await Socket.connect(_ipAddress, _broadcastPort);

        _broadcastSocket.listen(
          (List<int> data) {
            String receivedData = utf8.decode(data);

            if (receivedData == "scanner_state RUNNING") {
              ScanProvider.instance.startScan();
            }
            if (receivedData == "scanner_state CANCELLED") {
              ScanProvider.instance.cancelScan();
            }
            if (receivedData == "scanner_state FINISHED") {
              ScanProvider.instance.finishScan();
            }
            developer.log('Broadcast socket received data: $receivedData');
          },
          onDone: () {
            disconnectSockets();
            _isConnected = false;
            notifyListeners();

            developer.log('Broadcast socket closed');
          },
          onError: (error) {
            developer.log('Broadcast socket error: $error');
          },
        );
      } catch (e) {
        flag = false;
        developer.log("Error initializing broadcast socket: $e");
      }
    }

    if (flag) {
      try {
        _imageSocket = await Socket.connect(_ipAddress, _imagePort);

        _imageSocket.listen(
          (List<int> data) {
            String receivedData = utf8.decode(data);

            developer.log('Image socket received data: $receivedData');
          },
          onDone: () {
            disconnectSockets();
            _isConnected = false;
            notifyListeners();

            developer.log('Image socket closed');
          },
          onError: (error) {
            developer.log('Image socket error: $error');
          },
        );
      } catch (e) {
        flag = false;
        developer.log("Error initializing image socket: $e");
      }
    }
    if (flag) {
      try {
        _liveSocket = await Socket.connect(_ipAddress, _livePort);

        _liveSocket.listen(
          (List<int> data) async {
            String receivedData = utf8.decode(data);

            if (receivedData == "START_SCANNING") {
              _liveSocket.write(receivedData);
            }

            if (receivedData.startsWith("ROUND")) {
              List<String> parts = receivedData.split(" ");

              if (parts.length == 3) {
                try {
                  _currentRound = int.parse(parts[1]);
                  _totalRound = int.parse(parts[2]);
                  notifyListeners();
                } catch (e) {
                  developer.log("Error parsing integers: $e");
                }
              } else {
                developer.log("Invalid data format");
              }
              _liveSocket.write(receivedData);
            }
            if (receivedData == "FINISH_SCANNING") {
              _liveSocket.write(receivedData);
            }
            if (receivedData == "FILE_END") {
              _liveSocket.write(receivedData);
              fileSize = 0;
              // writeObjToFile(stringBuffer.toString());
            } else if (receivedData.startsWith("FILE")) {
              _totalRound = 0;
              _currentRound = 0;
              List<String> parts = receivedData.split(" ");
              try {
                int intValue = int.parse(parts[1]);
                fileSize = intValue;
              } catch (e) {
                developer.log("Error parsingh integers: $e");
              }
              _liveSocket.write(receivedData);
            }

            if (fileSize > 0) {
              stringBuffer.write(String.fromCharCodes(data));
              _liveSocket.write(receivedData);
              fileSize - receivedData.length;
            }
          },
          onDone: () {
            disconnectSockets();
            _isConnected = false;
            notifyListeners();

            developer.log('Live socket closed');
          },
          onError: (error) {
            developer.log('Live socket error: $error');
          },
        );
      } catch (e) {
        flag = false;
        developer.log("Error initializing live socket: $e");
      }
    }

    if (flag) {
      _isConnected = true;
      notifyListeners();
      developer.log('Sockets connected');
      _serverSocket.write("mobile");
    } else {
      showCustomToast(navigatorKey.currentContext!, "Can not connected!");
    }
  }

  int fileSize = 0;
  int count = 0;

  void disconnectSockets() {
    _configSocket.write("disconnect");
    _serverSocket.close();
    _configSocket.close();
    _broadcastSocket.close();
    _imageSocket.close();
    _liveSocket.close();
    _isConnected = false;
    notifyListeners();
  }

  void writeObjToFile(String objContent) async {
    try {
      // Open the file in write mode.
      File file = File(_filePath);
      IOSink sink = file.openWrite();

      // Write the content to the file.
      sink.write(objContent);

      // Close the file.
      await sink.flush().then((value) => sink.close().then((value) {
            SocketService.instance._isReceived = true;
            notifyListeners();
          }));
    } catch (e) {
      developer.log('Error writing to file: $e');
    }
  }

  void startScanCommand() {
    _configSocket.write("command start");
  }

  void cancelScanCommand() {
    _configSocket.write("command cancel");
  }

  void createFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String savedObjectsPath = '${directory.path}/received_files';

    if (!await Directory(savedObjectsPath).exists()) {
      await Directory(savedObjectsPath).create(recursive: true);
    }

    _filePath = '$savedObjectsPath/file.obj';

    File file = File(_filePath);
    await file.create();

    developer.log("name: ${file.path}");
  }

  String _filePath = "";

  void showCustomToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).disabledColor,
      ),
    );
  }
}
