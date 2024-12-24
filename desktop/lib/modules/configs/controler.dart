import 'basic.dart';
import 'package:isar/isar.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mtds/modules/file_bin/info.dart';

class BasicConfigController {
  // Private static instance
  static final BasicConfigController _instance =
      BasicConfigController._internal();

  // Static Isar instance to ensure it's opened only once
  static Isar? _isarInstance;

  // Private constructor
  BasicConfigController._internal() {
    _dir = getApplicationDocumentsDirectory();
    _isar = _getIsarInstance();
  }

  // Public factory constructor
  factory BasicConfigController() {
    return _instance;
  }

  late Future<Directory> _dir;
  late Future<Isar> _isar;

  Future<Isar> _getIsarInstance() async {
    if (_isarInstance == null) {
      final dir = await _dir;
      _isarInstance = Isar.openSync(
        [BasicConfigSchema],
        directory: dir.path,
        name: "basic_config",
      );
    }
    return _isarInstance!;
  }

  Future<void> put(BasicConfig info) async {
    final isar = await _isar;
    info.id = 0;
    await isar.writeTxn(() async {
      await isar.basicConfigs.put(info);
      print('write to config : ${info.token}');
    });
  }

  Future<BasicConfig?> read() async {
    final isar = await _isar;

    return await isar.basicConfigs.get(0);
  }

  Future<void> close() async {
    final isar = await _isar;
    await isar.close();
    print('closed isar');
  }
}
