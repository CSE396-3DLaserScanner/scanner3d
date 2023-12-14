import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scanner3d/src/services/socket_service.dart';

class ConnectionStatusAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<SocketService>(
      builder: (context, socketService, _) {
        return AppBar(
          backgroundColor: socketService.isConnected
              ? const Color.fromARGB(255, 36, 161, 157)
              : const Color.fromARGB(255, 209, 40, 40),
          title: Text(
            socketService.isConnected ? "Connected" : "No connection",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        );
      },
    );
  }
}
