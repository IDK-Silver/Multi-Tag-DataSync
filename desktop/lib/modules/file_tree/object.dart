import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mtds/modules/file_tree/object.dart';
import 'package:mtds/modules/configs/controler.dart';
import 'package:dio/dio.dart';
import 'dart:ffi';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mtds/modules/configs/controler.dart';
import 'package:mtds/modules/configs/basic.dart';
import 'package:mtds/modules/user.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:mtds/modules/api.dart';

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
    var dio = Dio();
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    final String url = (await getHostUrl()) + 'api/v1/file/info/';
    // final url = Uri.parse('https://api_mtds.yuufeng.com/api/v1/file/info/');
    try {
      final response = await dio.post(
        url.toString(),
        options: Options(headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }, followRedirects: true),
        data: jsonEncode({'uuid': uuid}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
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
            'Failed to load file info: ${response.statusCode}, ${response.data}');
        return null;
      }
    } catch (e) {
      print('Error in fromDB: $e');
      return null;
    }
  }

  static FileObjectNode fromDict(Map<String, dynamic> data) {
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
  }
}
