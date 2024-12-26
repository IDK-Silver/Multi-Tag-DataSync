import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:mtds/modules/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mtds/modules/configs/basic.dart';
import 'package:mtds/modules/file_tree/widget.dart';
import 'package:mtds/modules/file_tree/object.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:mtds/modules/api.dart';
import 'package:uuid/uuid.dart';
import 'package:mtds/modules/file_bin/controler.dart';
import 'package:mtds/modules/file_bin/info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mtds/modules/configs/controler.dart';
import 'package:mtds/pages/file/widget/tags.dart';

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
  String currentUuidString = '';
  String currentHashValue = '';
  List<String> currentTags = <String>[];
  CurrentFilePageWidgetState currentWidgetState = CurrentFilePageWidgetState();
  TextEditingController uploadFilePathTextEditerControler =
      TextEditingController();
  TextEditingController insertFileNameTextEditerControler =
      TextEditingController();

  bool currentFileInLocal = false;
  String currentFileLocalPath = '';

  FileBinaryController fileBinaryController = FileBinaryController();
  BasicConfigController basicConfigController = BasicConfigController();

  late Timer _timer;
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    checkConnect();
    treeController = TreeController<FileObjectNode>(
      roots: roots,
      childrenProvider: (FileObjectNode node) => node.children,
    );
    _startPeriodicExecution();
  }

  void _startPeriodicExecution() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isExecuting) {
        _executeCheckFileRequiredQueue();
      } else {
        print('Previous execution is still running. Skipping this cycle.');
      }
    });
  }

  Future<void> _executeCheckFileRequiredQueue() async {
    _isExecuting = true;
    try {
      await checkFileRequiredQueue();
    } finally {
      _isExecuting = false;
    }
  }

  Future<void> checkFileRequiredQueue() async {
    final token = await _getToken();
    if (token.isEmpty) {
      print('checkFileRequiredQueue : token is empty');
      return;
    }

    final queue = await fetchFileRequireQueue(token);

    if (queue == null) {
      print('queue is null');
      return;
    }

    var requiredUuidList = <String>[];

    for (var node in queue) {
      requiredUuidList.add(node.uuid);
    }

    for (final uuid in requiredUuidList) {
      final localInfo = await fileBinaryController.read(uuid);
      if (localInfo == null) continue;
      if (localInfo.path == null) continue;

      uploadFileToRequireQueue(token, uuid, localInfo.path!);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> downloadFileFromAnother() async {
    String token = await _getToken();
    if (token.isEmpty) return;

    final binaryData = await getBinaryFile(currentUuidString, token);

    if (binaryData == null) {
      print('bin is null');
      return;
    }

    // Get the directory to save the file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${filenameTextEditerControler.text}';

    // Write the bytes to the file
    final file = File(filePath);
    await file.writeAsBytes(binaryData);

    final binInfo = FileBinaryInfo()
      ..uuid = currentUuidString
      ..path = filePath
      ..hash = await getFileChecksum(filePath);
    fileBinaryController.put(binInfo);

    setState(() {
      fileBinaryController.put(binInfo);
      currentFileInLocal = true;
      currentFileLocalPath = filePath;
    });

    print('finish download');
  }

  Future<void> removeLocalFileInfo() async {
    fileBinaryController.delete(currentUuidString);

    setState(() {
      currentFileLocalPath = '';
      currentFileInLocal = false;
    });
  }

  Future<void> checkConnect() async {
    try {
      final token = await _getToken();

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
          print("file_page : checkConnect : fileobject is null");
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
    } catch (e) {
      return;
    }
  }

  Future<void> closeWidget() async {
    setState(() {
      currentWidgetState.setInsertFileMode(true);
      currentWidgetState.setInsertFileMode(false);
      insertFileNameTextEditerControler.clear();
      uploadFilePathTextEditerControler.clear();
    });
  }

  Future<String> _getToken() async {
    BasicConfig? existingConfig;

    try {
      existingConfig = await basicConfigController.read();
      if (existingConfig != null) {
        print("get token' Token : ${existingConfig.token}");
      } else {
        print('file page : _getToken() : token is null');
      }
    } catch (e) {
      print('Error reading config: $e');
    }

    if (existingConfig == null) {
      existingConfig = BasicConfig()
        ..id = 0
        ..apiURL = ''
        ..token = '';
    }

    return existingConfig.token ?? '';
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
      String hashValue = '';
      await getFileChecksum(uploadFilePathTextEditerControler.text)
          .then((hash) {
        if (hash != null) {
          hashValue = hash;
        }
      });

      var newNode = FileObjectNode(
          filename: insertFileNameTextEditerControler.text,
          uuid: const Uuid().v4(),
          parentUuid: node.uuid,
          children: <FileObjectNode>[],
          hash: hashValue);

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

      final binInfo = FileBinaryInfo()
        ..uuid = newNode.uuid
        ..path = uploadFilePathTextEditerControler.text
        ..hash = hashValue;
      fileBinaryController.put(binInfo);

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

  void _addTag(String tag) {
    setState(() {
      currentTags.add(tag);
    });
    _getToken().then((toekn) {
      addTagDB(toekn, currentUuidString, tag);
    });
  }

  void _deleteTag(String tag) {
    setState(() {
      currentTags.remove(tag);
    });
    _getToken().then((toekn) {
      deleteTagDB(toekn, currentUuidString, tag);
    });
  }

  List<FileObjectNode> roots = <FileObjectNode>[];

  late final TreeController<FileObjectNode> treeController;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      children: [
        Expanded(
            flex: 4,
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

                            currentUuidString = entry.node.uuid;

                            currentHashValue = entry.node.hash;

                            // fetch tage by API
                            _getToken().then((token) {
                              currentTags.clear();

                              getTagsByDocUuid(token, currentUuidString)
                                  .then((list) {
                                if (list != null) {
                                  setState(() {
                                    currentTags = list;
                                  });
                                }
                              });
                            });

                            fileBinaryController
                                .read(currentUuidString)
                                .then((binInfo) {
                              if (binInfo != null &&
                                  binInfo.path != null &&
                                  binInfo.path!.isNotEmpty) {
                                currentFileInLocal = true;
                                currentFileLocalPath = binInfo.path!;
                              } else {
                                currentFileInLocal = false;
                                currentFileLocalPath = "";
                              }
                            });
                          });
                        },
                      );
                    },
                  ))
                ],
              ),
            )),
        Expanded(
            flex: 4,
            child: Container(
              color: const Color.fromARGB(119, 239, 234, 234),
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
                                  enabled: false,
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
                          Expanded(
                              flex: 3, child: SelectableText(timestampString)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                      child: Row(
                        children: [
                          const Expanded(flex: 1, child: Text('UUID ')),
                          Expanded(
                              flex: 3,
                              child: SelectableText(currentUuidString)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                      child: Row(
                        children: [
                          const Expanded(flex: 1, child: Text('Hash ')),
                          Expanded(
                              flex: 3, child: SelectableText(currentHashValue)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                      child: Row(
                        children: [
                          const Expanded(flex: 1, child: Text('In Local')),
                          Expanded(
                              flex: 1,
                              child: Checkbox(
                                  value: currentFileInLocal,
                                  onChanged: (value) {})),
                          if (currentFileInLocal)
                            Expanded(
                                flex: 5,
                                child: SelectableText(currentFileLocalPath)),
                          if (currentFileInLocal)
                            Expanded(
                                flex: 1,
                                child: IconButton(
                                    onPressed: removeLocalFileInfo,
                                    icon: const Icon(Icons.delete))),
                          if (!currentFileInLocal)
                            Expanded(
                                flex: 1,
                                child: IconButton(
                                    onPressed: downloadFileFromAnother,
                                    icon: const Icon(Icons.download))),
                          if (!currentFileInLocal)
                            const Expanded(
                                flex: 5,
                                child: SizedBox(
                                  width: 10,
                                )),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                      child: Row(
                        children: [
                          const Expanded(flex: 1, child: Text('Tags ')),
                          Expanded(
                              flex: 3,
                              child: TagDisplay(
                                currentTags: currentTags,
                                onTagAdded: _addTag,
                                onTagDeleted: _deleteTag,
                              ))
                        ],
                      ),
                    )
                    // if (currentFileInLocal)
                    //   Container(
                    //     padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                    //     child: Row(
                    //       children: [
                    //         const Expanded(
                    //             flex: 1, child: Text('Local File Path : ')),
                    //         Expanded(
                    //             flex: 3, child: Text(currentFileLocalPath)),
                    //       ],
                    //     ),
                    //   ),
                  ],
                ),
                if (currentWidgetState.getInsertFileMode())
                  Positioned(
                      top: size.height * 0.01,
                      left: size.width * 0.01,
                      right: size.width * 0.01,
                      child: Container(
                        width: size.width * 0.98,
                        height: size.height * 0.98,
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
                                const Expanded(
                                    flex: 2, child: Text('File Name')),
                                Expanded(
                                    flex: 6,
                                    child: TextField(
                                      controller:
                                          insertFileNameTextEditerControler,
                                    )),
                                const Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      width: 0,
                                      height: 0,
                                    ))
                              ],
                            ),
                            Row(
                              children: [
                                const Expanded(flex: 2, child: Text('檔案路徑')),
                                Expanded(
                                    flex: 6,
                                    child: TextField(
                                      controller:
                                          uploadFilePathTextEditerControler,
                                    )),
                                Expanded(
                                  flex: 2,
                                  child: IconButton(
                                    onPressed: () async {
                                      FilePickerResult? chooseFilePath =
                                          await FilePicker.platform.pickFiles();
                                      if (chooseFilePath != null) {
                                        var filePath = chooseFilePath.files[0];

                                        uploadFilePathTextEditerControler.text =
                                            filePath.path!;

                                        insertFileNameTextEditerControler.text =
                                            filePath.name;
                                      }
                                    },
                                    icon: const Icon(Icons.file_open),
                                  ),
                                ),
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
                      top: size.height * 0.01,
                      left: size.width * 0.01,
                      right: size.width * 0.01,
                      child: Container(
                        width: size.width * 0.98,
                        height: size.height * 0.98,
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
                                const Expanded(
                                  flex: 2,
                                  child: Text('Folder Name : '),
                                ),
                                Expanded(
                                    flex: 8,
                                    child: TextField(
                                      controller:
                                          insertFileNameTextEditerControler,
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
