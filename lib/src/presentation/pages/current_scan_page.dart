import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scanner3d/src/local/shared_preferences.dart';
import 'package:scanner3d/src/model/file_data.dart';
import 'package:scanner3d/src/presentation/pages/render_page.dart';

class CurrentScanPage extends StatefulWidget {
  const CurrentScanPage({Key? key}) : super(key: key);

  @override
  State<CurrentScanPage> createState() => _CurrentScanPageState();
}

class _CurrentScanPageState extends State<CurrentScanPage> {
  late int totalTime;
  late int remainingTime;
  bool isScanning = false;

  @override
  void initState() {
    totalTime = 15;
    remainingTime = totalTime;
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfo(),
            isScanning ? _buildCancelButton() : _buildScanButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return isScanning
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 150),
              Container(
                  margin: const EdgeInsets.all(15),
                  child: const Text(
                    "You are almost done! We are scanning your object.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  )),
              const SizedBox(height: 50),
              CircularProgressIndicator(
                value: (totalTime - remainingTime) / totalTime,
                strokeWidth: 5.0,
              ),
              const SizedBox(height: 20),
              Text("%${(totalTime - remainingTime) * 100 ~/ totalTime}"),
              const SizedBox(height: 50),
              Text("Estimated Time: ${totalTime ~/ 60}m ${totalTime % 60}s"),
            ],
          )
        : Container(
            alignment: Alignment.center,
            child: Text(
              "Let's start a scanning in your 3D Object Scanner!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          );
  }

  Widget _buildCancelButton() {
    return Container(
      margin: const EdgeInsets.all(32),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 36, 161, 157),
          foregroundColor: Colors.white,
          fixedSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: () {
          setState(() {
            isScanning = false;
            remainingTime = totalTime;
          });
        },
        child: const Text("Cancel Scanning"),
      ),
    );
  }

  Widget _buildScanButton() {
    return Container(
      margin: const EdgeInsets.all(32),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 36, 161, 157),
          foregroundColor: Colors.white,
          fixedSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: () {
          isScanning = true;
          setState(() {
            receiveAndSaveFile();
          });
        },
        child: const Text("Scan Now"),
      ),
    );
  }

  List<FileData> savedObjects = [];

  Future<void> receiveAndSaveFile() async {
    // Socket üzerinden .obj dosyasını al ve yerel depolamaya kaydet
    // Bu kısmı gerçek bir socket bağlantısına ve veri alımına uygun olarak düzenlemeniz gerekebilir.
    // Alınan dosyayı 'savedObjects' klasörüne kaydet
    // delayedFunction(totalTime);
    for (int i = 0; i < 2; i++) {
      await Future.delayed(Duration(seconds: 1), () {
        remainingTime--;
      });
      if (!isScanning) {
        isScanning = false;

        break;
      }

      setState(() {});
    }

    String fileName = "teapot.obj";
    bool isSuccessful = true;
    int percentage = 100;

    try {
      Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      String savedObjectsPath = '${appDocumentsDirectory.path}/saved_objects';
      await Directory(savedObjectsPath).create(recursive: true);

      File file = File('$savedObjectsPath/$fileName');
      await file.writeAsString('File Content'); // Save details of file here

      savedObjects.add(FileData(
        fileName: fileName,
        isSuccessful: isSuccessful,
        percentage: percentage,
      ));

      SharedPreferencesOperations()
          .saveFileDataToSharedPreferences(savedObjects);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RenderPage(
              objectFileName: fileName, path: 'saved_objects/$fileName'),
        ),
      );
    } catch (e) {
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error while saving file: $e"),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {},
          ),
        ),
      );*/
    }
  }
}
