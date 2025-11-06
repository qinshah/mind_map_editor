import 'package:flutter/material.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/editor/editor_notifier.dart';
import 'package:provider/provider.dart';

class NodeWidget extends StatefulWidget {
  const NodeWidget(this.node, {super.key, this.onTap});

  final VoidCallback? onTap;
  final Node node;

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  final _focusNode = FocusNode();

  bool _focused = false;
  bool _hovering = false;

  late Color _primaryColor = Theme.of(context).colorScheme.primary;

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _primaryColor = Theme.of(context).colorScheme.primary;
    final depth = widget.node.path.length;
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
    final theme = depth == 1
        // 根节点
        ? NodeTheme(
            color: color,
            textStyle: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          )
        : depth == 2
        // 一级分支节点
        ? NodeTheme(
            color: color,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            textStyle: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          )
        : NodeTheme(
            color: color,
            textStyle: TextStyle(color: textColor),
          );
    final state = context.read<EditorNotifier>().state;
    final borderRadius = BorderRadius.circular(6);
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
          child: Container(
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(
                color: _focusNode.hasFocus || _hovering
                    ? _primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: LongPressDraggable(
              data: widget.node,
              feedback: Transform.scale(
                scale: state.scale / 100,
                child: Material(
                  color: Colors.transparent,
                  child: _buildChild(theme, borderRadius, alpha: 200),
                ),
              ),
              childWhenDragging: _buildChild(theme, borderRadius, alpha: 50),
              child: _buildChild(theme, borderRadius),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChild(NodeTheme theme, BorderRadius borderRadius, {int? alpha}) {
    return Ink(
      decoration: BoxDecoration(
        color: alpha == null ? theme.color : theme.color.withAlpha(alpha),
        borderRadius: borderRadius,
      ),
      child: InkWell(
        onFocusChange: (value) {
          if (_focused == value) return;
          setState(() => _focused = value);
        },
        focusNode: _focusNode,
        borderRadius: borderRadius,
        onTap: () {
          _focusNode.requestFocus();
          widget.onTap?.call();
        },
        child: Padding(
          padding: theme.padding,
          child: Text(widget.node.title, style: theme.textStyle),
        ),
      ),
    );
  }
}
