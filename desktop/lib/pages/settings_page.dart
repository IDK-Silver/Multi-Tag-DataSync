import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';

import 'package:mtds/modules/configs/basic.dart';

final _logger = Logger('SettingsPage');

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? selectedDirectory;
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [BasicConfigSchema],
      directory: dir.path,
    );

    final basicConfig = await isar.basicConfigs.get(0);

    if (basicConfig != null) {
      setState(() {
        _apiUrlController.text = basicConfig.apiURL ?? '';
        _tokenController.text = basicConfig.token ?? '';
      });
    }

    isar.close();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.settings,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),

            // API 設置區域
            const Text(
              'API 設置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'API URL',
              controller: _apiUrlController,
            ),
            _buildTextField(
              label: 'API Token',
              controller: _tokenController,
            ),

            // 資料夾選擇區域
            const SizedBox(height: 20),
            const Text(
              '同步設置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              selectedDirectory ?? '尚未選擇同步資料夾',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final directory = await FilePicker.platform.getDirectoryPath();
                if (directory != null) {
                  setState(() {
                    selectedDirectory = directory;
                  });
                }
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('選擇同步資料夾'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            // 保存按鈕
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                final dir = await getApplicationDocumentsDirectory();

                _logger.info('Using directory: ${dir.absolute.path}');

                final isar = await Isar.open(
                  [BasicConfigSchema],
                  directory: dir.path,
                );

                var existingConfig = await isar.basicConfigs.get(0);

                if (existingConfig == null) {
                  _logger.info('Creating new config');
                  existingConfig = BasicConfig()
                    ..id = 0
                    ..apiURL = _apiUrlController.text
                    ..token = _tokenController.text;
                } else {
                  existingConfig.apiURL = _apiUrlController.text;
                  existingConfig.token = _tokenController.text;
                }

                await isar.writeTxn(() async {
                  await isar.basicConfigs.put(existingConfig!);
                });

                isar.close();

                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('設定已保存')),
                  );
                }
              },
              child: const Text('保存設置'),
            ),
          ],
        ),
      ),
    );
  }
}
