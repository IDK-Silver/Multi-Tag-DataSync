import 'package:http/http.dart' as http;
import 'dart:ffi';
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class UserInfo {
  static final UserInfo _instance = UserInfo._internal();

  factory UserInfo() {
    return _instance;
  }

  UserInfo._internal();

  int? userId;
  String? username;
  String? hashedPassword;
  String? rootUuid;

  void setUserInfo({
    required int userId,
    required String username,
    required String hashedPassword,
    required String rootUuid,
  }) {
    this.userId = userId;
    this.username = username;
    this.hashedPassword = hashedPassword;
    this.rootUuid = rootUuid;
  }

  Map<String, dynamic> getUserInfo() {
    return {
      'user_id': userId,
      'username': username,
      'hashed_password': hashedPassword,
      'root_uuid': rootUuid,
    };
  }

  void clear() {
    userId = null;
    username = null;
    hashedPassword = null;
    rootUuid = null;
  }

  static Future<UserInfo?> fromDB(String token) async {
    var dio = Dio();
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    final url = Uri.parse('https://api_mtds.yuufeng.com/api/v1/auth/me');
    try {
      final response = await dio.get(url.toString(),
          options: Options(
            headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            followRedirects: true,
          ));

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        final userJson = jsonResponse['username'];
        return UserInfo()
          ..userId = userJson['user_id']
          ..username = userJson['username']
          ..hashedPassword = userJson['hashed_password']
          ..rootUuid = userJson['root_uuid'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

//   Future<void> fromDB(String token) async {
//     final url = Uri.parse('http://localhost:8000/api/v1/auth/me');
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           'accept': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         final userJson = jsonResponse['username'];
//         setUserInfo(
//           userId: userJson['user_id'],
//           username: userJson['username'],
//           hashedPassword: userJson['hashed_password'],
//           rootUuid: userJson['root_uuid'],
//         );
//       } else {
//         return;
//       }
//     } catch (e) {
//       return;
//     }
//   }
// }
}
