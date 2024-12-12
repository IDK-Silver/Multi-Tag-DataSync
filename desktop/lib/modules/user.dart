import 'package:http/http.dart' as http;
import 'dart:ffi';

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
    final url = Uri.parse('http://localhost:8000/api/v1/auth/me');
    try {
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
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
