import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/editor/editor_notifier.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_notifier.dart';
import 'package:provider/provider.dart';

class NodeWidget extends StatefulWidget {
  const NodeWidget(this.node, {super.key, this.onTap});

  final VoidCallback? onTap;
  final Node node;

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  late final _cntlr = TextEditingController(text: widget.node.title);

  late final _editor = context.read<EditorNotifier>();

  bool _hovering = false;

  late Color _primaryColor = Theme.of(context).colorScheme.primary;

  late final _theme = _buildTheme(widget.node.path.length);
  final _borderRadius = BorderRadius.circular(6);

  late MindMapNotifier _mindMap;

  late bool _focused;

  late bool _editing;

  NodeTheme _buildTheme(int depth) {
    final color = depth == 1
        ? _primaryColor
        // 控制相同分支色调一致
        : Colors.primaries[widget.node.path[1] % Colors.primaries.length]
              .withAlpha(
                255 - 60 * (depth - 2).clamp(0, 1), // 越深颜色越浅
              );
    final textColor = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    return switch (depth) {
      // 根节点
      0 => NodeTheme(
        color: color,
        textStyle: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      ),
      // 一级分支节点
      1 => NodeTheme(
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        textStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      int() => NodeTheme(
        color: color,
        textStyle: TextStyle(color: textColor),
      ),
    };
  }

  @override
  void dispose() {
    super.dispose();
    _cntlr.dispose();
    // _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _mindMap = context.watch<MindMapNotifier>();
    _focused = _mindMap.getFocused(widget.node);
    _editing = _mindMap.getEditing(widget.node);
    _primaryColor = Theme.of(context).colorScheme.primary;
    // if (_focused) print('节点${widget.node.path}聚焦');
    return DragTarget<Node>(
      onMove: (details) {
        final draggingNode = details.data;
        if (draggingNode.id == widget.node.id) return;
        // TODO 通过拖拽实现思维导图节点的移动
        // print(draggingNode.title);
        // print(details.offset);
      },
      builder: (_, _, _) {
        return MouseRegion(
          onHover: (_) {
            if (_hovering) return;
            setState(() => _hovering = true);
          },
          onExit: (_) {
            if (!_hovering) return;
            setState(() => _hovering = false);
          },
          child: LongPressDraggable(
            data: widget.node,
            feedback: Transform.scale(
              scale: _editor.state.scale / 100,
              child: Material(
                color: Colors.transparent,
                child: _buildChild(_theme, _borderRadius, alpha: 200),
              ),
            ),
            childWhenDragging: _buildChild(_theme, _borderRadius, alpha: 50),
            child: _buildChild(_theme, _borderRadius),
          ),
        );
      },
    );
  }

  Widget _buildChild(NodeTheme theme, BorderRadius borderRadius, {int? alpha}) {
    return InkWell(
      borderRadius: borderRadius,
      onTap: () {
        if (!_focused) _mindMap.foucsNode(widget.node);
        widget.onTap?.call();
      },
      child: IgnorePointer(
        ignoring: !_focused,
        child: GestureDetector(
          onTap: () => _mindMap.editNode(widget.node),
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              border: Border.all(
                color: _focused || _hovering
                    ? _primaryColor
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
                child:
                    //
                    Builder(
                      builder: (context) {
                        if (!_editing) {
                          return Text(
                            widget.node.title,
                            style: theme.textStyle,
                          );
                        }
                        if (_mindMap.state.selectionId == widget.node.id) {
                          _cntlr.selection = _mindMap.state.selection;
                        }
                        // TODO 解决在移动过程中计算输入框尺寸造成的卡顿问题
                        return IntrinsicWidth(
                          child: TextField(
                            autofocus: true,
                            maxLines: null,
                            style: theme.textStyle,
                            controller: _cntlr,
                            onTap: () {
                              _mindMap.saveSelection(
                                _cntlr.selection,
                                widget.node,
                              );
                            },
                            onChanged: (value) {
                              widget.node.title = value;
                              _mindMap.saveSelection(
                                _cntlr.selection,
                                widget.node,
                              );
                            },
                            decoration: InputDecoration(
                              isCollapsed: true,
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
