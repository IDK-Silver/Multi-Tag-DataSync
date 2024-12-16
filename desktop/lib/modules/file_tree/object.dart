import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum FileObjectType {
  file,
  directory,
}

extension FileObjectTypeExtension on FileObjectType {
  int get value {
    switch (this) {
      case FileObjectType.file:
        return 0;
      case FileObjectType.directory:
        return 1;
    }
  }
}

class FileObjectNode {
  final String uuid;
  final String parentUuid;
  final String filename;
  final FileObjectType type;
  final List<FileObjectNode> children;
  final DateTime? timestamp;
  final String hash;
  const FileObjectNode(
      {required this.filename,
      this.children = const <FileObjectNode>[],
      this.type = FileObjectType.file,
      this.uuid = '',
      this.parentUuid = '',
      this.hash = '',
      DateTime? inTimestamp})
      : timestamp = inTimestamp;

  // static Future<FileObjectNode> fromDB(String token, String uuid) async {
  //   final url = Uri.parse('http://localhost:8000/api/v1/file/info/');
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'accept': 'application/json',
  //       'Authorization': 'Bearer $token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({'uuid': uuid}),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return FileObjectNode(
  //         filename: data['filename'],
  //         uuid: data['uuid'],
  //         parentUuid: data['parent_id'],
  //         // 假設根目錄的type為directory
  //         type: data['d_id'] == '1'
  //             ? FileObjectType.directory
  //             : FileObjectType.file,
  //         children: <FileObjectNode>[]);
  //   } else {
  //     throw Exception('Failed to load file info');
  //   }
  // }
  static Future<FileObjectNode?> fromDB(String token, String uuid) async {
    final url = Uri.parse('http://localhost:8000/api/v1/file/info/');
    try {
      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'uuid': uuid}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FileObjectNode(
            filename: data['filename'] ?? '',
            uuid: data['uuid'] ?? '',
            parentUuid: data['parent_id'] ?? '',
            type: data['d_id'] == '1'
                ? FileObjectType.directory
                : FileObjectType.file,
            children: <FileObjectNode>[],
            hash: data['hash'],
            inTimestamp: DateTime.parse(data['timestamp']));
      } else {
        print(
            'Failed to load file info: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error in fromDB: $e');
      return null;
    }
  }

  // static FileObjectNode fromDict(Map<String, dynamic> dic) {}
}
