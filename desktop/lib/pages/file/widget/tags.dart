import 'package:flutter/material.dart';

class TagDisplay extends StatefulWidget {
  final List<String> currentTags;
  final Function(String) onTagAdded;
  final Function(String) onTagDeleted;

  const TagDisplay({
    Key? key,
    required this.currentTags,
    required this.onTagAdded,
    required this.onTagDeleted,
  }) : super(key: key);

  @override
  _TagDisplayState createState() => _TagDisplayState();
}

class _TagDisplayState extends State<TagDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0, // 調整標籤之間的水平間距
        runSpacing: 4.0, // 調整標籤之間的垂直間距
        children: [
          ...widget.currentTags.map((tag) => _buildTagItem(tag)).toList(),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildTagItem(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.cancel),
      onDeleted: () => widget.onTagDeleted(tag),
    );
  }

  Widget _buildAddButton() {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        _showAddTagDialog(context);
      },
    );
  }

  Future<void> _showAddTagDialog(BuildContext context) async {
    String newTag = '';
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('新增標籤'),
          content: TextField(
            onChanged: (value) {
              newTag = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('新增'),
              onPressed: () {
                if (newTag.isNotEmpty) {
                  widget.onTagAdded(newTag);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
