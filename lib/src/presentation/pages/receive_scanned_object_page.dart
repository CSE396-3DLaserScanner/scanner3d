import 'dart:io';

import 'package:Scanner3D/src/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Scanner3D/main.dart';
import 'package:Scanner3D/src/local/database_helper.dart';
import 'package:Scanner3D/src/model/file_data.dart';
import 'package:Scanner3D/src/presentation/pages/render_page.dart';
import 'package:Scanner3D/src/presentation/widgets/button_style.dart';
import 'package:provider/provider.dart';

class ReceiveScannedObjectPage extends StatefulWidget {
  const ReceiveScannedObjectPage({super.key});

  @override
  State<ReceiveScannedObjectPage> createState() =>
      _ReceiveScannedObjectPageState();
}

class _ReceiveScannedObjectPageState extends State<ReceiveScannedObjectPage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<FileData> savedObjects = [];

  final TextEditingController fileNameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() async {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: const EdgeInsets.all(50),
          alignment: Alignment.center,
          child: Consumer<SocketService>(builder: (context, socketService, _) {
            return socketService.isReceived
                ? _buildFileNameInput()
                : const CircularProgressIndicator();
          }),
        ));
  }

  Widget _buildFileNameInput() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Enter File Name",
            textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        Form(
          key: formKey,
          child: TextFormField(
              cursorColor: Theme.of(context).primaryColor,
              controller: fileNameController,
              decoration: InputDecoration(
                focusedBorder: getBorder(Theme.of(context).primaryColor),
                enabledBorder: getBorder(Theme.of(context).shadowColor),
                focusedErrorBorder: getBorder(Theme.of(context).disabledColor),
                errorBorder: getBorder(Theme.of(context).disabledColor),
                hintText: 'File Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a file name';
                }
                return null;
              }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ButtonStyles().textButton("Cancel", () {
              Navigator.of(context).pop();
            }, Theme.of(context).disabledColor),
            ButtonStyles().textButton("OK", () {
              if (formKey.currentState!.validate()) {
                saveAndNavigate("${fileNameController.text}.obj", 100);
                fileNameController.text.trim();
              }
            }, Theme.of(context).primaryColor),
          ],
        ),
      ],
    );
  }

  OutlineInputBorder getBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 1.0,
      ),
    );
  }

  Future<void> saveAndNavigate(String fileName, int percentage) async {
    bool isObjectValid = await _isObjectPathValid(fileName);

    if (isObjectValid) {
      await dbHelper.insertFileData(FileData(
        fileName: fileName,
        isSuccessful: percentage == 100,
        percentage: percentage,
      ));
    } else {
      percentage = 1;
      await dbHelper.insertFileData(FileData(
        fileName: fileName,
        isSuccessful: percentage == 100,
        percentage: percentage,
      ));
    }

    Navigator.pushReplacement(
      navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => RenderPage(
          objectFileName: fileName,
          path: 'received_files/$fileName',
        ),
      ),
    );
  }

  Future<bool> _isObjectPathValid(String fileName) async {
    String filePath =
        "/data/user/0/com.example.scanner3d/app_flutter/received_files/$fileName";
    try {
      File file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
