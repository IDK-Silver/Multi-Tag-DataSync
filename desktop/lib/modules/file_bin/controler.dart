import 'dart:io';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mtds/modules/configs/basic.dart';
import 'package:mtds/modules/file_bin/info.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as Path;

Future<String?> getFileChecksum(String filePath) async {
  try {
    File file = File(filePath);

    if (!await file.exists()) {
      print('File does not exist at path: $filePath');
      return null;
    }

    // Open the file as a stream
    Stream<List<int>> inputStream = file.openRead();

    // Create an MD5 hasher
    Digest checksum = await md5.bind(inputStream).first;

    return checksum.toString();
  } catch (e) {
    print('Error calculating checksum: $e');
    return null;
  }
}

class FileBinaryController {
  // Private static instance
  static final FileBinaryController _instance =
      FileBinaryController._internal();

  // Static Isar instance to ensure it's opened only once
  static Isar? _isarInstance;

  // Private constructor
  FileBinaryController._internal() {
    _dir = getApplicationDocumentsDirectory();
    _isar = _getIsarInstance();
  }

  // Public factory constructor
  factory FileBinaryController() {
    return _instance;
  }

  late Future<Directory> _dir;
  late Future<Isar> _isar;

  Future<Isar> _getIsarInstance() async {
    if (await _isarInstance == null) {
      final dir = Directory(
          '${(await _dir).absolute.path.toString()}${Platform.pathSeparator}.mtds');
      if (!(await dir.exists())) {
        dir.create(recursive: true);
      }

      _isarInstance = Isar.openSync(
        [FileBinaryInfoSchema],
        directory: dir.absolute.path.toString(),
        name: "file_binary_info",
      );
    }
    return _isarInstance!;
  }

  Future<void> put(FileBinaryInfo info) async {
    final isar = await _isar;

    await isar.writeTxn(() async {
      // Try to find existing record by uuid
      final existing = await isar.fileBinaryInfos
          .filter()
          .uuidEqualTo(info.uuid)
          .findFirst();
      if (existing != null) {
        // If exists, set id to update
        info.id = existing.id;
      }
      // Insert or update record
      await isar.fileBinaryInfos.put(info);
    });
  }

  Future<FileBinaryInfo?> read(String uuid) async {
    final isar = await _isar;

    // Find record by uuid
    return await isar.fileBinaryInfos.filter().uuidEqualTo(uuid).findFirst();
  }

  Future<void> delete(String uuid) async {
    final isar = await _isar;

    await isar.writeTxn(() async {
      await isar.fileBinaryInfos.filter().uuidEqualTo(uuid).deleteAll();
    });
  }

  Future<void> close() async {
    final isar = await _isar;
    await isar.close();
    print('closed isar');
  }
}
