import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mtds/modules/configs/basic.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isLogin = false;

  final TextEditingController _usernameTextEditer = TextEditingController();
  final TextEditingController _passwordTextEditer = TextEditingController();

  Future<void> _handleLogin() async {
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
    } else {
      // 登入失敗
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登入失敗')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
      ),
    );
  }
}
