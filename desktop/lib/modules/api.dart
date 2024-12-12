import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mtds/modules/file_tree/object.dart';

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
