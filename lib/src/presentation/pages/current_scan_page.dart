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
            return socketService.isConnected && scanProvider.isScanning
                ? _buildScanningScreen()
                : _buildInfoScreen();
          },
        ),
      ),
    );
  }

  Widget _buildInfoScreen() {
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
                  socketService.isConnected
                      ? scanProvider.startScan()
                      : showCustomToast(context, "No hardware connection");

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
                      value: (scanProvider.totalTime -
                              scanProvider.remainingTime) /
                          scanProvider.totalTime,
                      strokeWidth: 5.0,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "%${(scanProvider.totalTime - scanProvider.remainingTime) * 100 ~/ scanProvider.totalTime}",
                      style: TextStyle(
                          color: Theme.of(context).highlightColor,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Estimated Time: ${scanProvider.totalTime ~/ 60}m ${scanProvider.totalTime % 60}s",
                      style: TextStyle(
                          color: Theme.of(context).highlightColor,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 0,
                child: ButtonStyles().button(
                  "Cancel Scanning",
                  () {
                    scanProvider.cancelScan();
                  },
                  Theme.of(context).disabledColor,
                )),
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
