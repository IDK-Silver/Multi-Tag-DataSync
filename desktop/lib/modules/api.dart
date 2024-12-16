import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mtds/modules/file_tree/object.dart';
import 'package:mtds/modules/configs/controler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<List<String>?> getFileInfoChildren(String token, String uuid) async {
  const String url = 'http://localhost:8000/api/v1/file/info/children';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uuid': uuid,
      }),
    );

    if (response.statusCode == 200) {
      print('200 ok');
      print(response.body);
      // Assuming the API returns a JSON array of strings
      List<dynamic> jsonResponse = jsonDecode(response.body);
      List<String> ret = <String>[];

      for (dynamic value in jsonResponse) {
        ret.add(value['uuid']);
      }

      return ret;
    } else {
      return null;
      // throw Exception(
      //     'Failed to load file info children: ${response.statusCode}');
    }
  } catch (e) {
    return null;
    // throw Exception('Error occurred while fetching file info children: $e');
  }
}

Future<bool> modifyFileInfo(String token, FileObjectNode info) async {
  final url = Uri.parse('http://localhost:8000/api/v1/file/info/modify');
  try {
    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'filename': info.filename,
        'uuid': info.uuid,
        'parent_id': info.parentUuid,
        'd_id': info.type.value,
        'hash': info.hash,
      }),
    );

    if (response.statusCode == 200) {
      // 假设 200 状态码表示修改成功
      return true;
    } else {
      print('Failed to modify file info: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error in modifyFileInfo: $e');
    return false;
  }
}

Future<bool> deleteFileInfo(String token, FileObjectNode info) async {
  final url = Uri.parse('http://localhost:8000/api/v1/file/info/modify');
  try {
    final response = await http.delete(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uuid': info.uuid,
      }),
    );

    if (response.statusCode == 200) {
      // 假设 200 状态码表示修改成功
      return true;
    } else {
      print('Failed to delete file info: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Error in deleteFileInfo: $e');
    return false;
  }
}

List<int> _hexToBytes(String hex) {
  final bytes = <int>[];
  for (int i = 0; i < hex.length; i += 2) {
    final byte = hex.substring(i, i + 2);
    bytes.add(int.parse(byte, radix: 16));
  }
  return bytes;
}

Future<List<int>?> getBinaryFile(String uuid, String token) async {
  final url =
      Uri.parse('http://localhost:8000/api/v1/file/require_queue/$uuid');

  try {
    // Send GET request with Authorization header
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        final String filename = responseData['filename'];
        final String hexContent = responseData['content'];

        // Decode hex string to bytes
        // final bytes = hexToBytes(hexContent);

        return hexToBytes(hexContent);

        // // Get the directory to save the file
        // final directory = await getApplicationDocumentsDirectory();
        // final filePath = '${directory.path}/$filename';

        // // Write the bytes to the file
        // final file = File(filePath);
        // await file.writeAsBytes(bytes);

        // print('File saved successfully at $filePath');
        // return true;
      } else {
        print('Error: ${responseData['detail']}');
        return null;
      }
    } else if (response.statusCode == 404) {
      print('File not found in the queue.');
      return null;
    } else {
      print('Failed to download file. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('An error occurred: $e');
    return null;
  }
}

List<int> hexToBytes(String hex) {
  final bytes = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    String byteString = hex.substring(i, i + 2);
    bytes.add(int.parse(byteString, radix: 16));
  }
  return bytes;
}
