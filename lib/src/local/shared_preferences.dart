import 'dart:convert';

import 'package:scanner3d/src/model/file_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesOperations {
  Future<List<FileData>> getFileDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? fileDataStringList = prefs.getStringList('fileDataList');
    if (fileDataStringList != null) {
      return fileDataStringList
          .map((data) => FileData.fromJson(jsonDecode(data)))
          .toList();
    } else {
      return [];
    }
  }

  Future<void> saveFileDataToSharedPreferences(
      List<FileData> fileDataList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> fileDataStringList =
        fileDataList.map((data) => jsonEncode(data.toJson())).toList();
    prefs.setStringList('fileDataList', fileDataStringList);
  }
}
