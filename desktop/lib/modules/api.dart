import 'dart:convert';
import 'package:mtds/modules/file_tree/object.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:mtds/modules/user.dart';
import 'dart:io';
import 'package:dio/io.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mtds/modules/configs/controler.dart';

Future<String> getHostUrl() async {
  final basicConfigController = BasicConfigController();

  var config = await basicConfigController.read();
  if (config == null) {
    print("Failed to get host URL: Config does not exist.");
    return "https://localhost/"; // Return default URL if config is null
  }

  if (config.apiURL == null || config.apiURL!.isEmpty) {
    print("Warning: apiURL is empty or null, using default URL.");
    return "https://localhost/";
  }

  // Ensure API URL ends with a '/'
  if (!config.apiURL!.endsWith("/")) {
    config.apiURL = "${config.apiURL}/";
  }

  return config.apiURL!;
}

Future<List<String>?> getFileInfoChildren(String token, String uuid) async {
  var _apiDio = Dio();
  (_apiDio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  final String url = (await getHostUrl()) + 'api/v1/file/info/children';
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
  // final url = Uri.parse('https://api_mtds.yuufeng.com/api/v1/file/info/modify');
  final String url = (await getHostUrl()) + 'api/v1/file/info/modify';

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
  // final url = Uri.parse('https://api_mtds.yuufeng.com/api/v1/file/info/modify');
  final String url = (await getHostUrl()) + 'api/v1/file/info/modify';

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
  // final url =
  //     Uri.parse('https://api_mtds.yuufeng.com/api/v1/file/require_queue/$uuid');

  final url = (await getHostUrl()) + 'api/v1/file/require_queue/$uuid';

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
      final Map<String, dynamic> responseData = response.data;

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
  // final String apiUrl =
  //     'https://api_mtds.yuufeng.com/api/v1/file/require_queue/';

  final String apiUrl = (await getHostUrl()) + 'api/v1/file/require_queue/';
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
  // final url = Uri.parse('https://api_mtds.yuufeng.com/api/v1/auth/me');
  final String url = (await getHostUrl()) + 'api/v1/auth/me';

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

Future<void> uploadFileToRequireQueue(
    String token, String uuid, String filePath) async {
  // Create Dio instance
  var dio = Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  // Prepare the file to be uploaded
  var file = await MultipartFile.fromFile(filePath,
      contentType: MediaType('application', 'pdf'));

  // Prepare FormData
  FormData formData = FormData.fromMap({
    'file': file,
  });

  // Set headers
  Options options = Options(
    headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data'
    },
  );
  final String url = (await getHostUrl()) + 'api/v1/file/require_queue/$uuid';

  // Perform the POST request
  try {
    Response response = await dio.post(
      url,
      data: formData,
      options: options,
    );
    // Handle response from the server
    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
  } catch (e) {
    print('Error sending file: $e');
  }
}

Future<List<String>?> getTagsByDocUuid(String token, String uuid) async {
  // Create Dio instance
  var dio = Dio();
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  final String url = (await getHostUrl()) + 'api/v1/file/tag/$uuid';

  // Perform the POST request
  try {
    final response = await dio.get(url.toString(),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ));
    if (response.statusCode == 200) {
      final List<String> responseData = List<String>.from(response.data);
      print("getTagsByDocUuid conent : $responseData");
      return responseData;
    } else {
      print(
          'getTagsByDocUuid : respnese not 200 ${response.data['status_code']}');
      return null;
    }
  } catch (e) {
    print('getTagsByDocUuid : failed to fetch file tags: $e');
    return null;
  }
}

Future<bool> addTagDB(String token, String uuid, String tag) async {
  // Initialize Dio
  var dio = Dio();

  // Allow bad certificates (useful for development; remove in production)
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  // Construct the API URL
  final String url = (await getHostUrl()) + 'api/v1/file/tag/';

  try {
    // Prepare the request headers
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Prepare the request body
    final data = jsonEncode({
      'uuid': uuid,
      'tag': tag,
    });

    // Send the POST request
    final response = await dio.post(
      url,
      options: Options(headers: headers),
      data: data,
    );

    // Check the response status
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Assuming 200 or 201 indicates success
      print('Tag added successfully.');
      return true;
    } else {
      print(
          'Failed to add tag. Status code: ${response.statusCode}, Response: ${response.data}');
      return false;
    }
  } catch (e) {
    print('Error adding tag: $e');
    return false;
  }
}

Future<bool> deleteTagDB(String token, String uuid, String tag) async {
  // Initialize Dio
  var dio = Dio();

  // Allow bad certificates (useful for development; remove in production)
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };

  // Construct the API URL
  final String url = (await getHostUrl()) + 'api/v1/file/tag/';

  try {
    // Prepare the request headers
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Prepare the request body
    final data = jsonEncode({
      'uuid': uuid,
      'tag': tag,
    });

    // Send the DELETE request with a body
    final response = await dio.delete(
      url,
      options: Options(headers: headers),
      data: data,
    );

    // Check the response status
    if (response.statusCode == 200 || response.statusCode == 204) {
      // Assuming 200 OK or 204 No Content indicates success
      print('Tag deleted successfully.');
      return true;
    } else {
      print(
          'Failed to delete tag. Status code: ${response.statusCode}, Response: ${response.data}');
      return false;
    }
  } catch (e) {
    print('Error deleting tag: $e');
    return false;
  }
}

