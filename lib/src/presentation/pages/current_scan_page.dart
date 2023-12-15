import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:scanner3d/src/local/shared_preferences.dart';
import 'package:scanner3d/src/model/file_data.dart';
import 'package:scanner3d/src/presentation/pages/render_page.dart';
import 'package:scanner3d/src/presentation/widgets/button_style.dart';
import 'package:scanner3d/src/services/scan_provider.dart';
import '../../../main.dart';
import '../../services/notification_service.dart';
import '../../services/socket_service.dart';

class CurrentScanPage extends StatefulWidget {
  const CurrentScanPage({super.key});

  @override
  State<CurrentScanPage> createState() => _CurrentScanPageState();
}

class _CurrentScanPageState extends State<CurrentScanPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    SharedPreferencesOperations()
        .getFileDataFromSharedPreferences()
        .then((fileDataList) {
      setState(() {
        savedObjects = fileDataList;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SizedBox(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            alignment: Alignment.center,
            child: const Text(
              "Let's start a scanning in your 3D Object Scanner!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
          ButtonStyles().button(
            "Scan Now",
            () {
              scanProvider.onScanCompleted = receiveAndSaveFile;
              socketService.isConnected
                  ? scanProvider.startScan()
                  : showCustomToast(context, "No hardware connection");
            },
            const Color.fromARGB(255, 36, 161, 157),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        ],
      );
    });
  }

  Widget _buildScanningScreen() {
    return Consumer<ScanProvider>(
      builder: (context, scanProvider, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Container(
              margin: const EdgeInsets.all(15),
              child: const Text(
                "You are almost done! We are scanning your object.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
            CircularProgressIndicator(
              value: (scanProvider.totalTime - scanProvider.remainingTime) /
                  scanProvider.totalTime,
              strokeWidth: 5.0,
              color: const Color.fromARGB(255, 36, 161, 157),
            ),
            Text(
                "%${(scanProvider.totalTime - scanProvider.remainingTime) * 100 ~/ scanProvider.totalTime}"),
            Text(
                "Estimated Time: ${scanProvider.totalTime ~/ 60}m ${scanProvider.totalTime % 60}s"),
            ButtonStyles().button("Cancel Scanning", () {
              scanProvider.cancelScan();
            }, const Color.fromARGB(255, 193, 29, 29))
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
          backgroundColor: const Color.fromARGB(255, 193, 29, 29)),
    );
  }

  List<FileData> savedObjects = [];

  Future<void> receiveAndSaveFile() async {
    TextEditingController fileNameController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    String fileName = "new_scan.obj";
    int percentage = 100;

    NotificationService.showBigTextNotification(
        title: "Scanning completed successfully",
        body: "Let's take a look at the scanned object",
        fln: flutterLocalNotificationsPlugin);

    try {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: const Text("Enter File Name"),
                content: Form(
                  key: formKey,
                  child: TextFormField(
                      cursorColor: const Color.fromARGB(255, 36, 161, 157),
                      controller: fileNameController,
                      decoration: InputDecoration(
                        focusedBorder:
                            getBorder(const Color.fromARGB(255, 36, 161, 157)),
                        enabledBorder:
                            getBorder(const Color.fromARGB(255, 65, 65, 65)),
                        focusedErrorBorder:
                            getBorder(const Color.fromARGB(255, 193, 29, 29)),
                        errorBorder:
                            getBorder(const Color.fromARGB(255, 193, 29, 29)),
                        hintText: 'File Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a file name';
                        }
                        return null;
                      }),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      saveAndNavigate(context, fileName, percentage);
                    },
                    child: const Text("Cancel",
                        style:
                            TextStyle(color: Color.fromARGB(255, 193, 29, 29))),
                  ),
                  TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        fileName = "${fileNameController.text.trim()}.obj";
                        saveAndNavigate(context, fileName, percentage);
                      }
                    },
                    child: const Text("OK",
                        style: TextStyle(
                            color: Color.fromARGB(255, 36, 161, 157))),
                  ),
                ]);
          });
    } catch (e) {
      //
    }
  }

  Future<void> saveAndNavigate(
      BuildContext context, String fileName, int percentage) async {
    bool isObjectValid = await _isObjectPathValid('saved_objects/$fileName');

    if (isObjectValid) {
      saveFile(fileName, percentage);
    } else {
      percentage = 1;
      savedObjects.add(FileData(
        fileName: fileName,
        isSuccessful: false,
        percentage: percentage,
      ));
      SharedPreferencesOperations()
          .saveFileDataToSharedPreferences(savedObjects);
    }

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RenderPage(
          objectFileName: fileName,
          path: 'saved_objects/$fileName',
        ),
      ),
    );
  }

  Future<bool> _isObjectPathValid(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveFile(
    String fileName,
    int percentage,
  ) async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String savedObjectsPath = '${appDocumentsDirectory.path}/saved_objects';
    await Directory(savedObjectsPath).create(recursive: true);

    File file = File('$savedObjectsPath/$fileName');
    await file.writeAsString('File Content');

    await Future.delayed(const Duration(seconds: 1));

    savedObjects.add(FileData(
      fileName: fileName,
      isSuccessful: percentage == 100,
      percentage: percentage,
    ));

    SharedPreferencesOperations().saveFileDataToSharedPreferences(savedObjects);
  }

  OutlineInputBorder getBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 1.0,
      ),
    );
  }
}
