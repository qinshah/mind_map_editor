import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mind_map_editor/xmind/xnode_theme.dart';
import 'package:mind_map_editor/xmind/xmind.dart';
import 'package:mind_map_editor/editor/editor.dart';
import 'package:provider/provider.dart';

class XnodeWidget extends StatefulWidget {
  const XnodeWidget(this.node, {super.key, required this.theme});

  final Xnode node;

  final XnodeTheme theme;

  @override
  State<XnodeWidget> createState() => _XnodeWidgetState();
}

class _XnodeWidgetState extends State<XnodeWidget> {
  late final _node = widget.node;
  late final _editor = context.read<Editor>();
  late final _theme = widget.theme;

  final _borderRadius = BorderRadius.circular(6);

  late final _mTheme = Theme.of(context);

  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final focusedNode = context.select<Editor, Xnode?>((editor) {
      return editor.state.focusedNode;
    });
    _focused = _node.id == focusedNode?.id;
    return GestureDetector(
      onTap: () {
        if (!_focused) _editor.focus(_node);
      },
      child: DragTarget<Xnode>(
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
            feedback: ListenableBuilder(
              listenable: _editor,
              builder: (context, _) {
                final scale = _editor.state.zoom / 100;
                return Transform.scale(
                  scale: scale,
                  child: Material(
                    color: Colors.transparent,
                    child: _buildChild(_theme, _borderRadius, alpha: 200),
                  ),
                );
              },
            ),
            childWhenDragging: _buildChild(_theme, _borderRadius, alpha: 50),
            child: _buildChild(_theme, _borderRadius),
          );
        },
      ),
    );
  }

  static const defaultImgSize = 200.0;

  Widget _buildChild(
    XnodeTheme theme,
    BorderRadius borderRadius, {
    int? alpha,
  }) {
    final nodeImg = _node.image;
    final contents = [
      if (_node.imgPath != null)
        Image.file(
          File(_node.imgPath!),
          width: nodeImg!.width ?? defaultImgSize,
          height: nodeImg.height ?? defaultImgSize,
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: _focused ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: theme.color.withAlpha(alpha ?? 255),
          borderRadius: borderRadius,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              ignoring: !_focused,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _editor.showEditDialog(_node, context),
                child: Padding(
                  padding: theme.padding.add(
                    EdgeInsets.only(right: _node.subNodes.isNotEmpty ? 18 : 0),
                  ),
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
            if (_node.subNodes.isNotEmpty)
              Positioned(
                right: 5,
                child: GestureDetector(
                  onTap: () => _editor.toggleExpanded(_node),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _mTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _mTheme.colorScheme.onPrimary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_node.subNodes.length}',
                      style: TextStyle(color: _mTheme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
