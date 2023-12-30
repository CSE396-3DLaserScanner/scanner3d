import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Scanner3D/src/presentation/pages/receive_scanned_object_page.dart';
import 'package:Scanner3D/src/presentation/widgets/button_style.dart';
import 'package:Scanner3D/src/services/scan_provider.dart';
import '../../../main.dart';
import '../../services/notification_service.dart';
import '../../services/socket_service.dart';

class CurrentScanPage extends StatefulWidget {
  const CurrentScanPage({super.key});

  @override
  State<CurrentScanPage> createState() => _CurrentScanPageState();
}

class _CurrentScanPageState extends State<CurrentScanPage> {
  final formKey = GlobalKey<FormState>();
  final fileNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Consumer2<ScanProvider, SocketService>(
          builder: (context, scanProvider, socketService, _) {
            return socketService.isConnected
                ? _buildConnected()
                : _buildNotConnected();
          },
        ),
      ),
    );
  }

  Widget _buildConnected() {
    return Consumer2<ScanProvider, SocketService>(
      builder: (context, scanProvider, socketService, _) {
        return scanProvider.status == HardwareStatus.idle
            ? _buildStartScanScreen()
            : _buildScanningScreen();
      },
    );
  }

  Widget _buildNotConnected() {
    return Consumer2<ScanProvider, SocketService>(
      builder: (context, scanProvider, socketService, _) {
        return Column(
          children: [
            Expanded(
              flex: 10,
              child: Center(
                child: Text(
                  "Let's start a scanning in your 3D Object Scanner!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).highlightColor,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: ButtonStyles().button(
                "Scan Now",
                () {
                  showCustomToast(context, "No hardware connection");
                },
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStartScanScreen() {
    return Consumer2<ScanProvider, SocketService>(
      builder: (context, scanProvider, socketService, _) {
        return Column(
          children: [
            Expanded(
              flex: 10,
              child: Center(
                child: Text(
                  "Let's start a scanning in your 3D Object Scanner!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).highlightColor,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: ButtonStyles().button(
                "Scan Now",
                () {
                  socketService.startScanCommand();

                  scanProvider.onScanCompleted = () {
                    NotificationService.showBigTextNotification(
                      title: "Scanning completed successfully",
                      body: "Let's take a look at the scanned object",
                      fln: flutterLocalNotificationsPlugin,
                    );

                    navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (context) => const ReceiveScannedObjectPage(),
                      ),
                    );
                  };
                },
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScanningScreen() {
    return Consumer<ScanProvider>(
      builder: (context, scanProvider, _) {
        return Column(
          children: [
            Expanded(
              flex: 10,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "You are almost done! We are scanning your object.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    CircularProgressIndicator(
                        strokeWidth: 5.0,
                        color: Theme.of(context).primaryColor),
                    const SizedBox(height: 20),
                    Text(
                        "%${(SocketService.instance.currentRound / SocketService.instance.totalRound) * 100}"),
                  ],
                ),
              ),
            ),
            (scanProvider.status == HardwareStatus.scanning)
                ? Expanded(
                    flex: 0,
                    child: ButtonStyles().button(
                      "Cancel Scanning",
                      () {
                        SocketService.instance.cancelScanCommand();
                      },
                      Theme.of(context).disabledColor,
                    ))
                : const SizedBox(height: 0),
          ],
        );
      },
    );
  }

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
