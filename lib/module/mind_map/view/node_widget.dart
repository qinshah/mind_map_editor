import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/editor/editor_notifier.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_cntlr.dart';
import 'package:mind_map_editor/module/mind_map/view/node_edit_dialog.dart';
import 'package:provider/provider.dart';

class NodeWidget extends StatefulWidget {
  const NodeWidget(
    this.node, {
    super.key,
    this.onTap,
    required this.theme,
    required this.cntlr,
  });

  final VoidCallback? onTap;

  final Node node;

  final NodeTheme theme;

  final MindMapCntlr cntlr;

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  late final _node = widget.node;
  late final _editor = context.read<EditorNotifier>();
  late final _theme = widget.theme;

  final _borderRadius = BorderRadius.circular(6);

  late final _cntlr = widget.cntlr;

  late bool _focused;
  @override
  Widget build(BuildContext context) {
    _focused = _cntlr.getFocused(_node);
    return DragTarget<Node>(
      onMove: (details) {
        final draggingNode = details.data;
        if (draggingNode.id == _node.id) return;
        // TODO 通过拖拽实现思维导图节点的移动
        // print(draggingNode.title);
        // print(details.offset);
      },
      builder: (_, _, _) {
        return LongPressDraggable(
          data: _node,
          feedback: Transform.scale(
            scale: _editor.state.scale / 100,
            child: Material(
              color: Colors.transparent,
              child: _buildChild(_theme, _borderRadius, alpha: 200),
            ),
          ),
          childWhenDragging: _buildChild(_theme, _borderRadius, alpha: 50),
          child: _buildChild(_theme, _borderRadius),
        );
      },
    );
  }

  Widget _buildChild(NodeTheme theme, BorderRadius borderRadius, {int? alpha}) {
    final nodeImg = _node.image;
    final contents = [
      if (_node.imgPath != null)
        Image.file(
          File(_node.imgPath!),
          // TODO 默认尺寸
          width: nodeImg!.width ?? 200,
          height: nodeImg.height ?? 200,
        ),
      Text(_node.title, style: theme.textStyle),
    ];
    final vertical = switch (nodeImg?.align) {
      ImgAlign.top || ImgAlign.bottom => true,
      _ => false,
    };
    final children = switch (nodeImg?.align) {
      ImgAlign.right || ImgAlign.bottom => contents.reversed.toList(),
      _ => contents,
    };
    return InkWell(
      borderRadius: borderRadius,
      onTap: () {
        if (!_focused) _cntlr.foucs(_node);
        widget.onTap?.call();
      },
      child: IgnorePointer(
        ignoring: !_focused,
        child: GestureDetector(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (_) => NodeEditDialog(_node),
            );
            _cntlr.rebuild(widget.node);
          },
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              border: Border.all(
                color: _focused
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: borderRadius,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.color.withAlpha(alpha ?? 255),
                borderRadius: borderRadius,
              ),
              child: Padding(
                padding: theme.padding,
                child: Flex(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: vertical
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  direction: vertical ? Axis.vertical : Axis.horizontal,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
