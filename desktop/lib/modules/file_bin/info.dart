import 'package:isar/isar.dart';

part 'info.g.dart';

@collection
class FileBinaryInfo {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String? uuid;

  String? path;

  String? hash;

  DateTime? timestamp;
}
