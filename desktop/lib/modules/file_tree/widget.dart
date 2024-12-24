import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'object.dart';

class FileObjectTile extends StatelessWidget {
  const FileObjectTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final TreeEntry<FileObjectNode> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // Wrap your content in a TreeIndentation widget which will properly
      // indent your nodes (and paint guides, if required).
      //
      // If you don't want to display indent guides, you could replace this
      // TreeIndentation with a Padding widget, providing a padding of
      // `EdgeInsetsDirectional.only(start: TreeEntry.level * indentAmount)`
      child: TreeIndentation(
        entry: entry,
        // Provide an indent guide if desired. Indent guides can be used to
        // add decorations to the indentation of tree nodes.
        // This could also be provided through a DefaultTreeIndentGuide
        // inherited widget placed above the tree view.
        guide: const IndentGuide.connectingLines(indent: 48),
        // The widget to render next to the indentation. TreeIndentation
        // respects the text direction of `Directionality.maybeOf(context)`
        // and defaults to left-to-right.
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: Row(
            children: [
              // Add a widget to indicate the expansion state of this node.
              // See also: ExpandIcon.
              FolderButton(
                  isOpen: entry.node.type == FileObjectType.directory
                      ? entry.isExpanded
                      : null,
                  onPressed: entry.hasChildren ? onTap : null),
              Text(entry.node.filename),
            ],
          ),
        ),
      ),
    );
  }
}
