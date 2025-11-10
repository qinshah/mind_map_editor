import 'package:flutter/material.dart';
import 'package:mind_map_editor/xmind/xmind.dart';

class EditDialog extends StatefulWidget {
  const EditDialog(this.node, {super.key});

  final Xnode node;

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late final _cntlr = TextEditingController(text: widget.node.title);

  @override
  void dispose() {
    super.dispose();
    _cntlr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        maxLines: null,
        controller: _cntlr,
        onChanged: (value) => widget.node.title = value,
        decoration: InputDecoration(
          isCollapsed: true,
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
