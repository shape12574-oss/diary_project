import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final double latitude;
  final double longitude;


  DiaryEntry.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        content = json['content'],
        latitude = json['latitude'],
        longitude = json['longitude'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class DiaryStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/diaries.json');
  }

  Future<File> writeDiaries(List<DiaryEntry> diaries) async {
    final file = await _localFile;
    final String jsonString = json.encode(diaries.map((d) => d.toJson()).toList());
    return file.writeAsString(jsonString);
  }
}