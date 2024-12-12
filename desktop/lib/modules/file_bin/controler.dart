import 'dart:io';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mtds/modules/configs/basic.dart';
import 'package:mtds/modules/file_bin/info.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

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

// class FileBinaryController {
//   // 私有靜態實例
//   static final FileBinaryController _instance =
//       FileBinaryController._internal();

//   FileBinaryController._internal() {
//     _dir = getApplicationDocumentsDirectory();
//     _isar = _openIsar();
//   }

//   // 公共工廠構造函數，返回單例實例
//   factory FileBinaryController() {
//     return _instance;
//   }

//   late Future<Directory> _dir;
//   late Future<Isar> _isar;

//   Future<Isar> _openIsar() async {
//     final dir = await _dir;
//     return await Isar.open(
//       [FileBinaryInfoSchema],
//       directory: dir.path,
//       name: "file_binary_info",
//     );
//   }

//   Future<void> put(FileBinaryInfo info) async {
//     final isar = await _isar;

//     await isar.writeTxn(() async {
//       // 嘗試根據 uuid 查找現有記錄
//       final existing = await isar.fileBinaryInfos
//           .filter()
//           .uuidEqualTo(info.uuid)
//           .findFirst();
//       if (existing != null) {
//         // 如果存在，設置 id 以便更新
//         info.id = existing.id;
//       }
//       // 插入或更新記錄
//       await isar.fileBinaryInfos.put(info);
//     });
//   }

//   Future<FileBinaryInfo?> read(String uuid) async {
//     final isar = await _isar;

//     // 根據 uuid 查找記錄
//     return await isar.fileBinaryInfos.filter().uuidEqualTo(uuid).findFirst();
//   }

//   Future<void> delete(String uuid) async {
//     final isar = await _isar;

//     await isar.writeTxn(() async {
//       await isar.fileBinaryInfos.filter().uuidEqualTo(uuid).deleteAll();
//     });
//   }

//   Future<void> close() async {
//     final isar = await _isar;
//     await isar.close();
//     print('closed isar');
//   }
// }
class FileBinaryController {
  // Private static instance
  static final FileBinaryController _instance =
      FileBinaryController._internal();

  // Static Isar instance to ensure it's opened only once
  static Future<Isar>? _isarInstance;

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
    if (_isarInstance == null) {
      final dir = await _dir;
      _isarInstance = Isar.open(
        [FileBinaryInfoSchema],
        directory: dir.path,
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
