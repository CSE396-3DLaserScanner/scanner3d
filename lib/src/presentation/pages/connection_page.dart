import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanner3d/src/presentation/widgets/button_style.dart';
import 'package:scanner3d/src/services/socket_service.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect to Hardware'),
        centerTitle: true,
      ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _ipController,
            decoration: const InputDecoration(labelText: 'Enter Server IP'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the server IP';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _portController,
            decoration: const InputDecoration(labelText: 'Enter Port'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the port';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ButtonStyles.button(
            "Connect",
            () {
              if (_formKey.currentState!.validate()) {
                // Form is valid, continue with connection logic
                String ipAddress = _ipController.text;
                String port = _portController.text;
                Provider.of<SocketService>(context, listen: false)
                    .connectSocket(ipAddress, port);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionInfoScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
            "Hardware IP Address: ${_ipController.text}:${_portController.text}"),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Provider.of<SocketService>(context, listen: false)
                .disconnectSocket();
          },
          child: const Text('Disconnect'),
        ),
      ],
    );
  }
}
