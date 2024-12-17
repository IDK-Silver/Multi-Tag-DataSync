import 'dart:convert';
import 'package:mtds/modules/file_tree/object.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:mtds/modules/user.dart';
import 'dart:io';
import 'package:dio/io.dart';

Future<List<String>?> getFileInfoChildren(String token, String uuid) async {
  var _apiDio = Dio();
  (_apiDio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  const String url = 'https://api_mtds.yuufeng.com/api/v1/file/info/children';
  try {
    final response = await _apiDio.post(
      Uri.parse(url).toString(),
      options: Options(headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
      data: jsonEncode({
        'uuid': uuid,
      }),
    );

    if (response.statusCode == 200) {
      print('200 ok');
      // print(response.);
      // Assuming the API returns a JSON array of strings
      List<dynamic> jsonResponse = response.data;
      List<String> ret = <String>[];

      for (dynamic value in jsonResponse) {
        ret.add(value['uuid']);
      }

      return ret;
    } else {
      print('API : faild to get childern');
      return null;
      // throw Exception(
      //     'Failed to load file info children: ${response.statusCode}');
    }
  } catch (e) {
    print('API : faild to get childern');

    return null;
    // throw Exception('Error occurred while fetching file info children: $e');
  }
}

Future<bool> modifyFileInfo(String token, FileObjectNode info) async {
  var _apiDio = Dio();
  (_apiDio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  final url = Uri.parse('https://api_mtds.yuufeng.com/api/v1/file/info/modify');
  try {
    final response = await _apiDio.post(
      url.toString(),
      options: Options(headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
      data: jsonEncode({
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
  var _apiDio = Dio();
  (_apiDio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  final url = Uri.parse('https://api_mtds.yuufeng.com/api/v1/file/info/modify');
  try {
    final response = await _apiDio.delete(
      url.toString(),
      options: Options(headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
      data: jsonEncode({
        'uuid': info.uuid,
      }),
    );

    if (response.statusCode == 200) {
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
  var _apiDio = Dio();
  (_apiDio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  final url =
      Uri.parse('https://api_mtds.yuufeng.com/api/v1/file/require_queue/$uuid');

  try {
    final response = await _apiDio.get(url.toString(),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> responseData =
          json.decode(response.data.toString());

      if (responseData['status'] == 'success') {
        final String filename = responseData['filename'];
        final String hexContent = responseData['content'];

        return hexToBytes(hexContent);
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

Future<List<FileObjectNode>?> fetchFileRequireQueue(String token) async {
  final String apiUrl =
      'https://api_mtds.yuufeng.com/api/v1/file/require_queue/';
  var _apiDio = Dio();
  (_apiDio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  try {
    final response = await _apiDio.get(Uri.parse(apiUrl).toString(),
        options: Options(
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
    var retList = <FileObjectNode>[];
    if (response.statusCode == 200) {
      List<dynamic> datas = response.data;
      for (var data in datas) {
        // print(data);
        retList.add(FileObjectNode.fromDict(data));
      }
      return retList;
    } else {
      print('Failed to load data: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

Future<UserInfo?> _getUserInfo(String token) async {
  var _apiDio = Dio();
  (_apiDio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  final url = Uri.parse('https://api_mtds.yuufeng.com/api/v1/auth/me');
  UserInfo info;

  try {
    final response = await _apiDio.get(url.toString(),
        options: Options(
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          followRedirects: true,
        ));

    if (response.statusCode == 200) {
      final userJson = response.data['username'];
      info = UserInfo();
      info.setUserInfo(
        userId: userJson['user_id'],
        username: userJson['username'],
        hashedPassword: userJson['hashed_password'],
        rootUuid: userJson['root_uuid'],
      );
      return info;
    } else {
      print('failded to get user info');
      print(response.data);
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}
