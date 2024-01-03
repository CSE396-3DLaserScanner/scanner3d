import 'dart:io';

import 'package:Scanner3D/main.dart';
import 'package:flutter/material.dart';
import 'package:Scanner3D/src/local/database_helper.dart';
import 'package:Scanner3D/src/model/file_data.dart';
import 'package:Scanner3D/src/presentation/pages/render_page.dart';

class ScanListPage extends StatefulWidget {
  const ScanListPage({super.key});

  @override
  State<ScanListPage> createState() => _ScanListPageState();
}

class _ScanListPageState extends State<ScanListPage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Scans',
          style: TextStyle(color: Theme.of(context).highlightColor),
        ),
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Theme.of(context).shadowColor,
      ),
      body: Center(
        child: FutureBuilder<List<FileData>>(
          future: dbHelper.getFileDataList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  "No scanned object found!\nScan an object.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20, color: Theme.of(context).shadowColor),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ObjectCard(
                    myObject: snapshot.data![index],
                    onDelete: () async {
                      await dbHelper.deleteFileData(snapshot.data![index].id!);
                      await deleteFile(snapshot.data![index].filePath,
                          snapshot.data![index].filePath);
                      refreshData();
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  void refreshData() {
    setState(() {});
  }

  Future<void> deleteFile(String filePath, String fileName) async {
    try {
      File file = File(filePath);

      // Dosya var mı kontrol et
      if (await file.exists()) {
        await file.delete();
        showCustomToast(
            navigatorKey.currentContext!, 'File deleted: $fileName');
      } else {
        showCustomToast(
            navigatorKey.currentContext!, 'File not found: $filePath');
      }
    } catch (e) {
      showCustomToast(navigatorKey.currentContext!,
          'An error occurred while deleting the file: $e');
    }
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

class ObjectCard extends StatelessWidget {
  final FileData myObject;
  final VoidCallback onDelete;

  const ObjectCard({
    super.key,
    required this.myObject,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        color: Colors.white30,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RenderPage(
                  objectFileName: myObject.fileName,
                  path: myObject.filePath,
                ),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                myObject.isSuccessful ? Icons.check_circle : Icons.cancel,
                color: myObject.isSuccessful
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    myObject.fileName,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              myObject.percentage < 100
                  ? Text("${myObject.percentage}%")
                  : const Text(""),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              )
            ],
          ),
        ),
      ),
    );
  }
}
