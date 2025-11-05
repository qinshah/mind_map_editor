import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_notifier.dart';
import 'package:mind_map_editor/module/mind_map/view/line_painter.dart';
import 'package:mind_map_editor/module/mind_map/view/node_widget.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:provider/provider.dart';

class MindMap extends StatefulWidget {
  final Node rootNode;
  const MindMap(this.rootNode, {super.key});

  @override
  State<MindMap> createState() => _MindMapState();
}

class _MindMapState extends State<MindMap> {
  Node get rootNode => widget.rootNode;
  final _nodeKey = GlobalKey();
  Offset _nodeOut = Offset.zero;
  final List<Offset> _childIn = [];
  final List<GlobalKey> _childKeys = [];

  @override
  void initState() {
    super.initState();
    _childKeys.addAll(rootNode.childNodes.map((e) => GlobalKey()));
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePoints());
  }

  @override
  void didUpdateWidget(covariant MindMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rootNode.childNodes.length != rootNode.childNodes.length) {
      _childKeys.clear();
      _childKeys.addAll(rootNode.childNodes.map((e) => GlobalKey()));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePoints());
  }

  Future<void> _updatePoints() async {
    final notifier = context.read<MindMapNotifier>();
    if (!mounted) return;
    if (!notifier.getExpanded(rootNode.id)) {
      if (_childIn.isNotEmpty) {
        setState(() {
          _childIn.clear();
        });
      }
      return;
    }
    final nodeRenderBox = _nodeKey.currentContext?.findRenderObject() as RenderBox?;
    if (nodeRenderBox == null) return;

    final nodeOut = nodeRenderBox.localToGlobal(Offset(nodeRenderBox.size.width, nodeRenderBox.size.height / 2));

    final childIn = <Offset>[];
    for (var key in _childKeys) {
      final childRenderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (childRenderBox == null) continue;
      final childInOffset = childRenderBox.localToGlobal(Offset(0, childRenderBox.size.height / 2));
      childIn.add(childInOffset);
    }

    final stackRenderBox = context.findRenderObject() as RenderBox;
    final newNodeOut = stackRenderBox.globalToLocal(nodeOut);
    final newChildIn = childIn.map((e) => stackRenderBox.globalToLocal(e)).toList();

    if (newNodeOut != _nodeOut ||
        _childIn.length != newChildIn.length ||
        _childIn.toString() != newChildIn.toString()) {
      setState(() {
        _nodeOut = newNodeOut;
        _childIn.clear();
        _childIn.addAll(newChildIn);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MindMapNotifier>();
    final depth = rootNode.path.length;
    final theme = depth == 1
        ? MindMapTheme(spacingBetweenChild: 20, spacingWithChild: 40)
        : depth == 2
        ? MindMapTheme(spacingBetweenChild: 10, spacingWithChild: 30)
        : MindMapTheme();

    return Stack(
      children: [
        if (_childIn.isNotEmpty)
          CustomPaint(
            painter: LinePainter(
              context: context,
              start: _nodeOut,
              ends: _childIn,
            ),
          ),
        Row(
          children: [
            NodeWidget( rootNode,
              key: _nodeKey,
              onTap: () {
                notifier.toggleExpand(rootNode.id);
              },
            ),
            if (notifier.getExpanded(rootNode.id) && rootNode.childNodes.isNotEmpty) ...[
              SizedBox(width: theme.spacingWithChild),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(rootNode.childNodes.length, (index) {
                  final childNode = rootNode.childNodes[index];
                  return Padding(
                    padding: index == 0
                        ? EdgeInsets.zero
                        : EdgeInsets.only(top: theme.spacingBetweenChild),
                    child: MindMap(
                      childNode,
                      key: _childKeys[index],
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
