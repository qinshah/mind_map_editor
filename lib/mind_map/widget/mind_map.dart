import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mind_map_editor/mind_map/m_m_node.dart';
import 'package:mind_map_editor/mind_map/m_m_theme.dart';
import 'package:mind_map_editor/mind_map/m_m_cntlr.dart';

typedef NodeBuilder<T extends MMNode> = Widget Function(T node, List<int> path);

typedef ThemeBuilder = MMTheme Function(List<int> path);

class MindMap<T extends MMNode> extends StatelessWidget {
  const MindMap(
    this.node, {
    super.key,
    required this.nodeWidgetBuilder,
    required this.cntlr,
    required this.path,
    required this.themeBuilder,
    required this.keyBuilder,
  });

  const MindMap.root(
    this.node, {
    super.key,
    required this.nodeWidgetBuilder,
    required this.cntlr,
    required this.themeBuilder,
    required this.keyBuilder,
  }) : path = const [];

  MindMap<T> buildSubTree(T subNode, {required List<int> subPath}) {
    return MindMap(
      subNode,
      nodeWidgetBuilder: nodeWidgetBuilder,
      cntlr: cntlr,
      path: subPath,
      themeBuilder: themeBuilder,
      keyBuilder: keyBuilder,
    );
  }

  final MMCntlr<T> cntlr;

  final T node;

  final List<int> path;

  final Key Function(T node) keyBuilder;

  final NodeBuilder<T> nodeWidgetBuilder;

  final ThemeBuilder themeBuilder;

  @override
  Widget build(BuildContext context) {
    cntlr.saveNodePath(node, path);
    return ListenableBuilder(
      listenable: cntlr,
      builder: (BuildContext context, _) {
        final expanded = cntlr.getExpanded(node);
        return Container(
          color: kDebugMode
              ? Colors.primaries[node.hashCode % Colors.primaries.length]
                    .withAlpha(66)
              : null,
          child: RenderMindMapWidget(
            theme: themeBuilder(path),
            key: keyBuilder(node),
            nodeWidget: nodeWidgetBuilder(node, path),
            expandButton: node.subNodes.isEmpty
                ? null
                : _buildExpandButton(
                    onTap: () => cntlr.toggleExpanded(node),
                    childCount: node.subNodes.length,
                  ),
            subtrees: expanded
                ? List.generate(node.subNodes.length, (index) {
                    final subNode = node.subNodes[index] as T;
                    return buildSubTree(subNode, subPath: [...path, index]);
                  })
                : [],
            expanded: expanded,
          ),
        );
      },
    );
  }

  // TODO 展开按钮放到节点处理
  static Widget _buildExpandButton({
    required VoidCallback onTap,
    required int childCount,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(9999),
      onTap: onTap,
      child: SizedBox(
        width: 20,
        height: 20,
        child: Center(child: Text('$childCount')),
      ),
    );
  }
}

class RenderMindMapWidget extends MultiChildRenderObjectWidget {
  const RenderMindMapWidget({
    required this.theme,
    super.key,
    required this.nodeWidget,
    required this.subtrees,
    required this.expanded,
    required this.expandButton,
  });

  final MMTheme theme;

  @override
  List<Widget> get children => [nodeWidget, ?expandButton, ...subtrees];

  final bool expanded;

  final Widget nodeWidget;

  final Widget? expandButton;

  final List<MindMap> subtrees;
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMindMap(theme: theme, expanded: expanded);
  }
}

class RenderMindMap extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MindMapParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MindMapParentData> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! MindMapParentData) {
      child.parentData = MindMapParentData();
    }
  }

  final bool expanded;

  final MMTheme theme;

  RenderMindMap({required this.theme, required this.expanded});

  void offsetEButton({
    required Size eBSize,
    required MindMapParentData eBPData,
  }) {
    final root = firstChild!;
    final rootSize = root.size;
    final rootPData = root.parentData as MindMapParentData;
    eBPData.offset = rootPData.offset.translate(
      rootSize.width + 3,
      rootSize.height / 2 - eBSize.height / 2,
    );
  }

  @override
  void performLayout() {
    final root = firstChild!;
    final rootPData = root.parentData as MindMapParentData;
    root.layout(constraints, parentUsesSize: true);
    final rootSize = root.size;
    size = rootSize;
    final expandButton = rootPData.nextSibling;
    if (expandButton == null) return; // 叶子节点，return
    expandButton.layout(constraints, parentUsesSize: true);
    final eBSize = expandButton.size;
    final eBPData = expandButton.parentData as MindMapParentData;
    if (!expanded) {
      offsetEButton(eBPData: eBPData, eBSize: eBSize);
      size = Size(eBPData.offset.dx + eBSize.width, rootSize.height);
      // 没有展开，不绘制子树，return
      return;
    }
    final firstSubTree = eBPData.nextSibling!;
    firstSubTree.layout(constraints, parentUsesSize: true);
    final xOffset = rootSize.width + theme.spacingWithSubTree;
    (firstSubTree.parentData as MindMapParentData).offset = Offset(xOffset, 0);
    RenderBox widestSubTree = firstSubTree;
    RenderBox? nextSubTree = childAfter(firstSubTree);
    double nextYOffset = firstSubTree.size.height + theme.spacingBetweenSubTree;
    while (nextSubTree != null) {
      nextSubTree.layout(constraints, parentUsesSize: true);
      if (nextSubTree.size.width > widestSubTree.size.width) {
        widestSubTree = nextSubTree;
      }
      final parentData = nextSubTree.parentData as MindMapParentData;
      parentData.offset = Offset(xOffset, nextYOffset);
      nextYOffset += nextSubTree.size.height + theme.spacingBetweenSubTree;
      nextSubTree = parentData.nextSibling;
    }
    final width = xOffset + widestSubTree.size.width;
    final subTreesHeight = nextYOffset - theme.spacingBetweenSubTree;
    if (subTreesHeight > rootSize.height) {
      size = Size(width, subTreesHeight);
      rootPData.offset = Offset(0, (subTreesHeight - rootSize.height) / 2);
    } else {
      size = Size(width, rootSize.height);
      final moreTranslateY = (rootSize.height - subTreesHeight) / 2;
      nextSubTree = rootPData.nextSibling;
      while (nextSubTree != null) {
        final parentData = nextSubTree.parentData as MindMapParentData;
        parentData.offset += Offset(0, moreTranslateY);
        nextSubTree = parentData.nextSibling;
      }
    }
    offsetEButton(eBSize: eBSize, eBPData: eBPData);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final root = firstChild!;
    final rootPData = root.parentData as MindMapParentData;
    final rootOffset = rootPData.offset + offset;
    context.paintChild(root, rootOffset);
    final expandButton = rootPData.nextSibling;
    if (expandButton == null) return; // 叶子节点，直接return
    final lienFrom = rootOffset + Offset(root.size.width, root.size.height / 2);
    if (expanded) {
      // 展开了再绘制子树
      RenderBox? subtree = childAfter(expandButton);
      while (subtree != null) {
        final parentData = subtree.parentData as MindMapParentData;
        final subtreeOffset = parentData.offset + offset;
        context.paintChild(subtree, parentData.offset + offset);
        drawLine(
          context.canvas,
          lienFrom,
          subtreeOffset + Offset(0, subtree.size.height / 2),
        );
        subtree = parentData.nextSibling;
      }
    }
    drawLine(context.canvas, lienFrom, lienFrom + Offset(3, 0));
    context.paintChild(
      expandButton,
      (expandButton.parentData as MindMapParentData).offset + offset,
    );
  }

  /// 从 [from] 到 [to] 画一条 XMind 风格的贝塞尔曲线
  /// [thickness] 线宽，[color] 颜色
  void drawLine(
    Canvas canvas,
    Offset from,
    Offset to, {
    Color color = const Color(0xFF4A90E2),
    double thickness = 1.5,
  }) {
    // 1. 水平或垂直的“主方向”
    final delta = to - from;
    final path = Path()..moveTo(from.dx, from.dy);

    // 2. 控制点：让曲线“甩”出去
    //    系数 0.6 可以调，越大曲线越“弯”
    const double k = 0.6;
    final Offset c1 = from + Offset(delta.dx * k, 0);
    final Offset c2 = to - Offset(delta.dx * k, 0);

    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, to.dx, to.dy);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..color = color
        ..isAntiAlias = true,
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class MindMapParentData extends ContainerBoxParentData<RenderBox> {}
