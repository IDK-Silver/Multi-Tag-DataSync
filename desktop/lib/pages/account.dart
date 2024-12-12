import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mtds/modules/configs/basic.dart';
import 'package:mtds/modules/user.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();

    _tryLogin();
    // Timer.periodic(Duration(seconds: 10), (timer) {
    // });
  }

  bool isLogin = true;

  final TextEditingController _usernameTextEditer = TextEditingController();
  final TextEditingController _passwordTextEditer = TextEditingController();

  Future<void> _tryLogin() async {
    _getToken().then((token) {
      _getUserInfo(token).then((info) {
        if (info != null) {
          setState(() {
            _usernameTextEditer.text = info.username!;
            isLogin = true;
          });
        } else {
          setState(() {
            isLogin = false;
          });
        }
      });
    });
  }

  Future<UserInfo?> _getUserInfo(String token) async {
    final url = Uri.parse('http://localhost:8000/api/v1/auth/me');
    UserInfo info;

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
        info = UserInfo();
        info.setUserInfo(
          userId: userJson['user_id'],
          username: userJson['username'],
          hashedPassword: userJson['hashed_password'],
          rootUuid: userJson['root_uuid'],
        );
        return info;
      } else {
        // throw Exception('Failed to load user info');
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無法連接到伺服器，請確認伺服器是否已啟動')),
      );
      isLogin = false;
    }
  }

  Future<void> _handleLogin() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/v1/auth/login'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'password',
          'username': _usernameTextEditer.text,
          'password': _passwordTextEditer.text,
          'scope': '',
          'client_id': 'string',
          'client_secret': 'string'
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // 登入成功
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登入成功')),
        );
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['access_token'];
        await _saveToken(accessToken);
        setState(() {
          isLogin = true;
        });
      } else {
        // 登入失敗
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登入失敗')),
        );
        isLogin = false;
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無法連接到伺服器，請確認伺服器是否已啟動')),
      );
      isLogin = false;
    }
  }

  Future<void> _handeLogout() async {
    _saveToken('');
    _passwordTextEditer.text = '';
    setState(() {
      isLogin = false;
    });
  }

  Future<void> _saveToken(String accessToken) async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [BasicConfigSchema],
      directory: dir.path,
    );

    var existingConfig = await isar.basicConfigs.get(0);

    if (existingConfig == null) {
      existingConfig = BasicConfig()
        ..id = 0
        ..apiURL = ''
        ..token = accessToken;
    } else {
      existingConfig.token = accessToken;
    }

    await isar.writeTxn(() async {
      await isar.basicConfigs.put(existingConfig!);
    });

    isar.close();
  }

  Future<String> _getToken() async {
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open(
      [BasicConfigSchema],
      directory: dir.path,
    );

    var existingConfig = await isar.basicConfigs.get(0);

    if (existingConfig == null) {
      existingConfig = BasicConfig()
        ..id = 0
        ..apiURL = ''
        ..token = '';
    }

    isar.close();

    return existingConfig.token!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Visibility(
            visible: !isLogin,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '登入',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _usernameTextEditer,
                      obscureText: false,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: '使用者名稱',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _passwordTextEditer,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: '密碼',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '登入',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            )),
        Visibility(
            visible: isLogin,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text(
                      "使用者名稱",
                      style: TextStyle(fontSize: 32),
                    ),
                    const Padding(padding: EdgeInsets.all(20.0)),
                    Text(
                      _usernameTextEditer.text,
                      style: const TextStyle(fontSize: 32),
                    )
                  ]),
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: _handeLogout,
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontSize: 32),
                      ))
                ],
              ),
            ))
      ]),
    );
  }
}
