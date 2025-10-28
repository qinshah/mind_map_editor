import 'package:flutter/material.dart';
import 'package:mind_map_editor/editor/editor_notifier.dart';
import 'package:mind_map_editor/model/xmind.dart';
import 'package:provider/provider.dart';

class MindMap extends StatefulWidget {
  const MindMap(this.root, {super.key});

  final Node root;

  @override
  State<MindMap> createState() => _MindMapState();
}

class _MindMapState extends State<MindMap> {
  late final List<_Node> _nodes;

  final _nodeHeight = 50.0;

  final _nodeWidth = 100.0;

  // @override
  // void initState() {
  //   _nodes = _treeToList(widget.root);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<EditorNotifier>();
    final state = notifier.state;
    return Stack(
      children: [
        SizedBox(width: state.width, height: state.height),
        ..._treeToList(widget.root).map(
          (node) => Positioned(
            left: node.left,
            top: node.top,
            child: Container(
              width: _nodeWidth,
              height: _nodeHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(child: Text(node.data.title)),
            ),
          ),
        ),
      ],
    );
  }

  // TODO 正确layout脑图
  List<_Node> _treeToList(Node root, [int index = 0, int depth = 0]) {
    final node = [_Node(root, depth * _nodeWidth * 0.2, index++ * _nodeHeight)];
    for (final child in root.childNodes) {
      node.addAll(_treeToList(child, index, depth + 1));
    }
    return node;
  }

  // List<_Node> _treeToList(Node root) {
  //   final children = [];
  //   for (final child in root.childNodes) {
  //     children.add(_Node(child, 0, 0));
  //   }
  // }
}

class _Node {
  final Node data;
  double left;
  double top;

  _Node(this.data, this.left, this.top);
}
