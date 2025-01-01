import 'package:isar/isar.dart';

part 'basic.g.dart';

@collection
class BasicConfig {
  Id id = Isar.autoIncrement; // 你也可以用 id = null 来表示 id 是自增的

  String? apiURL;

  String? token;

  String? realStoragePath;

  bool? isLogin;
}
