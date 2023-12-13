import 'package:flutter/material.dart';
import 'package:scanner3d/src/local/shared_preferences.dart';
import 'package:scanner3d/src/model/file_data.dart';
import 'package:scanner3d/src/presentation/pages/render_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScanListPage extends StatefulWidget {
  const ScanListPage({super.key});

  @override
  State<ScanListPage> createState() => _ScanListPageState();
}

class _ScanListPageState extends State<ScanListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Scans'),
        centerTitle: true,
        forceMaterialTransparency: true,
        backgroundColor: Colors.white10,
      ),
      body: Center(
        child: ListView.builder(
          itemCount: savedObjects.length,
          itemBuilder: (context, index) {
            return ObjectCard(
              myObject: savedObjects[index],
              onDelete: () {
                savedObjects.remove(savedObjects[index]);
                SharedPreferencesOperations()
                    .saveFileDataToSharedPreferences(savedObjects);
                setState(() {});
              },
            );
          },
        ),
      ),
    );
  }

  List<FileData> savedObjects = [];

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Success Indicator Icon
            Icon(
              myObject.isSuccessful ? Icons.check_circle : Icons.cancel,
              color: myObject.isSuccessful
                  ? const Color.fromARGB(255, 36, 161, 157)
                  : const Color.fromARGB(255, 193, 29, 29),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RenderPage(
                        objectFileName: myObject.fileName,
                        path: 'saved_objects/${myObject.fileName}',
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    myObject.fileName,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            myObject.percentage < 100
                ? Text("${myObject.percentage}%")
                : const Text(""),
            // Delete Button
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
