import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:mtds/modules/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mtds/modules/configs/basic.dart';
import 'package:http/http.dart' as http;
import 'package:mtds/modules/file_tree/widget.dart';
import 'package:mtds/modules/file_tree/object.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:mtds/modules/api.dart';
import 'package:uuid/uuid.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<StatefulWidget> createState() => _FilePageState();
}

class CurrentFilePageWidgetState {
  bool _insertFile = false;
  bool _insertFolder = false;
  bool connect = false;
  bool showConnectErrorMessage = false;

  void setInsertFileMode(bool mode) {
    _insertFile = mode;
    if (mode == true) {
      _insertFolder = false;
    }
  }

  bool getInsertFileMode() {
    return _insertFile;
  }

  void setInsertFolderMode(bool mode) {
    _insertFolder = mode;
    if (mode == true) {
      _insertFile = false;
    }
  }

  bool getInsertFolderMode() {
    return _insertFolder;
  }
}

class _FilePageState extends State<FilePage> {
  TextEditingController filenameTextEditerControler = TextEditingController();
  TreeEntry<FileObjectNode>? currentTreeEntry;
  String timestampString = '';
  CurrentFilePageWidgetState currentWidgetState = CurrentFilePageWidgetState();
  int counter = 0;

  TextEditingController insertFileNameTextEditerControler =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    checkConnect();
    treeController = TreeController<FileObjectNode>(
      roots: roots,
      childrenProvider: (FileObjectNode node) => node.children,
    );
  }

  Future<void> checkConnect() async {
    try {
      _getToken().then((token) {
        UserInfo userInfo = UserInfo();

        if (token.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('未登入'),
                duration: Duration(seconds: 3),
              ),
            );
          });
          currentWidgetState.connect = false;
          return;
        }
        // print(token);
        // print(userInfo.getUserInfo());

        UserInfo.fromDB(token).then((user) {
          if (user != null && user.rootUuid != null) {
            FileObjectNode.fromDB(token, user.rootUuid!).then((node) {
              if (node != null) {
                roots.add(node);
                treeController.rebuild();
                buildTree(roots[0]);
              }
            });
            currentWidgetState.connect = true;
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('未登入'),
                  duration: Duration(seconds: 3),
                ),
              );
            });
            currentWidgetState.connect = false;
          }
        });
      });
    } catch (e) {
      return;
    }
  }

  Future<void> closeWidget() async {
    setState(() {
      currentWidgetState.setInsertFileMode(true);
      currentWidgetState.setInsertFileMode(false);
      insertFileNameTextEditerControler.clear();
    });
  }

  Future<String> _getToken() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [BasicConfigSchema],
      directory: dir.path,
    );

    var existingConfig = await isar.basicConfigs.get(0);

    if (existingConfig == null) {
      isar.close();
      return '';
    }

    isar.close();
    print('close isar');
    return existingConfig.token!;
  }

  Future<void> refreshTreeRoot() async {
    if (!currentWidgetState.connect) {
      checkConnect();
      return;
    }
    roots[0].children.clear();
    buildTree(roots[0]);
    treeController.rebuild();
  }

  Future<void> insertFiletNode() async {
    if (!currentWidgetState.connect) {
      checkConnect();
      return;
    }
    if (currentTreeEntry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請選擇要新增的位置')),
      );
      return;
    }

    FileObjectNode node = currentTreeEntry!.node;

    while (
        node.type == FileObjectType.file && currentTreeEntry?.parent != null) {
      currentTreeEntry = currentTreeEntry!.parent;
      node = currentTreeEntry!.node;
    }

    if (node.type == FileObjectType.directory) {
      var newNode = FileObjectNode(
          filename: insertFileNameTextEditerControler.text,
          uuid: const Uuid().v4(),
          parentUuid: node.uuid,
          children: <FileObjectNode>[]);

      _getToken().then((token) {
        modifyFileInfo(token, newNode).then((succ) {
          if (!succ) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('更新資料庫錯誤')),
            );
            return;
          }
        });
      });

      setState(() {
        node.children.add(newNode);
        insertFileNameTextEditerControler.clear();
        closeWidget();
      });
    }
    treeController.rebuild();
    currentWidgetState.setInsertFolderMode(false);
  }

  Future<void> insertDirectoryNode() async {
    if (!currentWidgetState.connect) {
      checkConnect();
      return;
    }
    if (currentTreeEntry == null) return;

    FileObjectNode node = currentTreeEntry!.node;

    while (
        node.type == FileObjectType.file && currentTreeEntry?.parent != null) {
      currentTreeEntry = currentTreeEntry!.parent;
      node = currentTreeEntry!.node;
    }

    if (node.type == FileObjectType.directory) {
      var newNode = FileObjectNode(
          filename: insertFileNameTextEditerControler.text,
          uuid: const Uuid().v4(),
          parentUuid: node.uuid,
          type: FileObjectType.directory,
          children: <FileObjectNode>[]);

      _getToken().then((token) {
        modifyFileInfo(token, newNode).then((succ) {
          if (!succ) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('更新資料庫錯誤')),
            );
            return;
          }
        });
      });

      setState(() {
        node.children.add(newNode);
        insertFileNameTextEditerControler.clear();
        closeWidget();
      });
    }
    treeController.rebuild();
  }

  Future<void> deleteFileObjectNode() async {
    if (!currentWidgetState.connect) {
      checkConnect();
      return;
    }
    if (currentTreeEntry == null) return;

    FileObjectNode node = currentTreeEntry!.node;

    TreeEntry<FileObjectNode>? parentEntry = currentTreeEntry?.parent;

    if (parentEntry == null) return;

    FileObjectNode parent_node = parentEntry.node;

    _getToken().then((token) {
      deleteFileInfo(token, node).then((ret) {
        if (ret) {
          parent_node.children.remove(node);
          treeController.rebuild();

          setState(() {
            filenameTextEditerControler.clear();
            timestampString = '';
          });
        }
      });
    });
  }

  Future<void> buildTree(FileObjectNode? node) async {
    _getToken().then((token) {
      if (node != null) {
        getFileInfoChildren(token, node.uuid).then((childUuids) {
          if (childUuids != null) {
            for (String childUUid in childUuids) {
              FileObjectNode.fromDB(token, childUUid).then((childNode) {
                if (childNode != null) {
                  node.children.add(childNode);
                  if (childNode.type == FileObjectType.directory) {
                    buildTree(childNode);
                  }
                }
              });
            }
          }
        });
      }
    });
    return;
  }

  List<FileObjectNode> roots = <FileObjectNode>[];

  @override
  void dispose() {
    // Remember to dispose your tree controller to release resources.
    treeController.dispose();
    super.dispose();
  }

  late final TreeController<FileObjectNode> treeController;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Container(
              color: const Color.fromARGB(255, 245, 245, 245),
              child: Column(
                children: [
                  Container(
                    color: const Color.fromARGB(186, 209, 207, 207),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (!currentWidgetState.connect) {
                              checkConnect();
                              return;
                            }
                            refreshTreeRoot();
                          },
                          child: const Icon(Icons.autorenew),
                        ),
                        TextButton(
                          onPressed: () {
                            if (!currentWidgetState.connect) {
                              checkConnect();
                              return;
                            }
                            setState(() {
                              currentWidgetState.setInsertFileMode(true);
                            });
                          },
                          style: TextButton.styleFrom(),
                          child: const Icon(Icons.feed),
                        ),
                        TextButton(
                            onPressed: () {
                              if (!currentWidgetState.connect) {
                                checkConnect();
                                return;
                              }
                              setState(() {
                                currentWidgetState.setInsertFolderMode(true);
                              });
                            },
                            child: const Icon(Icons.create_new_folder)),
                        TextButton(
                            onPressed: () {
                              if (!currentWidgetState.connect) {
                                checkConnect();
                                return;
                              }
                              deleteFileObjectNode();
                            },
                            child: const Icon(Icons.delete))
                      ],
                    ),
                  ),
                  Expanded(
                      child: TreeView<FileObjectNode>(
                    treeController: treeController,
                    nodeBuilder: (BuildContext context,
                        TreeEntry<FileObjectNode> entry) {
                      return FileObjectTile(
                        key: ValueKey(entry.node),
                        entry: entry,
                        onTap: () {
                          treeController.toggleExpansion(entry.node);
                          currentTreeEntry = entry;
                          setState(() {
                            filenameTextEditerControler.text =
                                entry.node.filename;
                            if (entry.node.timestamp != null) {
                              timestampString = entry.node.timestamp.toString();
                            }
                          });
                        },
                      );
                    },
                  ))
                ],
              ),
            )),
        Expanded(
            flex: 2,
            child: Container(
              color: Color.fromARGB(119, 239, 234, 234),
              child: Stack(children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 32,
                    ),
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Row(
                        children: [
                          const Expanded(flex: 1, child: Text('Filename')),
                          Expanded(
                              flex: 3,
                              child: TextField(
                                  controller: filenameTextEditerControler,
                                  decoration: const InputDecoration(
                                    labelText: '',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                      child: Row(
                        children: [
                          const Expanded(flex: 1, child: Text('Timestamp ')),
                          Expanded(flex: 3, child: Text(timestampString)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (currentWidgetState.getInsertFileMode())
                  Positioned(
                      top: size.height * 0.1,
                      left: size.width * 0.1,
                      right: size.width * 0.1,
                      child: Container(
                        width: size.width * 0.9,
                        height: size.height * 0.9,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          border: Border.all(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text('File Name : '),
                                const SizedBox(width: 20),
                                Expanded(
                                    child: TextField(
                                  controller: insertFileNameTextEditerControler,
                                ))
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: insertFiletNode,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '新增',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: closeWidget,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '取消',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                if (currentWidgetState.getInsertFolderMode())
                  Positioned(
                      top: size.height * 0.1,
                      left: size.width * 0.1,
                      right: size.width * 0.1,
                      child: Container(
                        width: size.width * 0.9,
                        height: size.height * 0.9,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          border: Border.all(
                              color: const Color.fromARGB(255, 91, 76, 175),
                              width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text('Folder Name : '),
                                const SizedBox(width: 20),
                                Expanded(
                                    child: TextField(
                                  controller: insertFileNameTextEditerControler,
                                ))
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: insertDirectoryNode,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '新增',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: closeWidget,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '取消',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
              ]),
            ))
      ],
    );
  }
}
