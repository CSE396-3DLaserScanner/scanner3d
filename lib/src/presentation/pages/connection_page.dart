import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanner3d/src/presentation/widgets/button_style.dart';
import 'package:scanner3d/src/services/socket_service.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({Key? key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  final TextEditingController _ipController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<SocketService>(
          builder: (context, socketService, _) {
            return socketService.isConnected
                ? _buildConnectionInfoScreen()
                : _buildConnectScreen();
          },
        ),
      ),
    );
  }

  Widget _buildConnectScreen() {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 100),
            const Text(
              "Connect to Device",
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            SizedBox(
              height: 120,
              child: Column(
                children: [
                  TextFormField(
                    cursorColor: const Color.fromARGB(255, 36, 161, 157),
                    controller: _ipController,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 36, 161, 157),
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 65, 65, 65),
                          width: 1.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 193, 29, 29),
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 193, 29, 29),
                          width: 2.0,
                        ),
                      ),
                      labelText: 'Enter Server IP',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 65, 65, 65),
                      ),
                      hintText: "127.0.0.1",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the server IP';
                      }

                      if (!isValidIpAddress(value)) {
                        return 'Invalid IP address format';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
            ButtonStyles().button(
              "Connect",
              () {
                if (_formKey.currentState!.validate()) {
                  String ipAddress = _ipController.text;
                  Provider.of<SocketService>(context, listen: false)
                      .connectSocket(ipAddress);
                }
              },
              const Color.fromARGB(255, 36, 161, 157),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionInfoScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Center vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          const SizedBox(height: 100),
          SizedBox(
            height: 80,
            child: Column(
              children: [
                const Text(
                  "Hardware IP Address:",
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Consumer<SocketService>(
                  builder: (context, socketService, _) {
                    return Text(
                      socketService.ipAddress,
                      style: const TextStyle(fontSize: 20),
                    );
                  },
                ),
              ],
            ),
          ),
          ButtonStyles().button(
            "Disconnect",
            () {
              Provider.of<SocketService>(context, listen: false)
                  .disconnectSocket();
            },
            const Color.fromARGB(255, 193, 29, 29),
          ),
        ],
      ),
    );
  }

  bool isValidIpAddress(String value) {
    try {
      InternetAddress(value);
      return true;
    } catch (_) {
      return false;
    }
  }
}
