import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_cntlr.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/mind_map/view/node_widget.dart';

typedef NodeBuilder = NodeWidget Function(Node node, List<int> path);

typedef ThemeBuilder = MindMapTheme Function(List<int> path);

class MindMap extends StatelessWidget {
  const MindMap(
    this.node, {
    super.key,
    required this.nodeBuilder,
    required this.cntlr,
    required this.path,
    required this.themeBuilder,
  });

  const MindMap.root(
    this.node, {
    required super.key,
    required this.nodeBuilder,
    required this.cntlr,
    required this.themeBuilder,
  }) : path = const [];

  MindMap buildSubTree(Node subNode, {required List<int> subPath}) {
    return MindMap(
      subNode,
      nodeBuilder: nodeBuilder,
      cntlr: cntlr,
      path: subPath,
      themeBuilder: themeBuilder,
    );
  }

  final MindMapCntlr cntlr;

  final Node node;

  final List<int> path;

  final NodeBuilder nodeBuilder;

  final ThemeBuilder themeBuilder;

  @override
  Widget build(BuildContext context) {
    // print('构建${rootNode.title}');
    return ListenableBuilder(
      listenable: cntlr,
      builder: (BuildContext context, _) {
        final expanded = cntlr.getExpanded(node.id);
        final childCount = node.subNodes.length;
        final showExpandButton = node.subNodes.isNotEmpty;
        return Container(
          // TODO 去掉区域背景色
          color: Colors.primaries[node.hashCode % Colors.primaries.length]
              .withAlpha(66),
          child: RenderMindMapWidget(
            theme: themeBuilder(path),
            key: UniqueKey(),
            nodeWidget: nodeBuilder(node, path),
            expandButton: showExpandButton
                ? _buildExpandButton(
                    onTap: () => cntlr.toggleExpand(node.id),
                    childCount: childCount,
                  )
                : SizedBox(),
            subtrees: !expanded
                ? []
                : List.generate(childCount, (index) {
                    final subNode = node.subNodes[index];
                    return buildSubTree(subNode, subPath: [...path, index]);
                  }),
            showExpandButton: showExpandButton,
            expandButtonSize: expandButtonSize,
          ),
        );
      },
    );
  }

  static const expandButtonSize = 16.0;

  // TODO 展开按钮放到节点处理
  static Widget _buildExpandButton({
    required VoidCallback onTap,
    required int childCount,
  }) {
    return SizedBox(
      width: expandButtonSize,
      height: expandButtonSize,
      child: Ink(
        decoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
        child: InkWell(
          borderRadius: BorderRadius.circular(expandButtonSize / 2),
          onTap: onTap,
          child: Center(
            child: Text('$childCount', style: TextStyle(fontSize: 10)),
          ),
        ),
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
    required this.expandButton,
    required this.showExpandButton,
    required this.expandButtonSize,
  });

  final MindMapTheme theme;

  final bool showExpandButton;

  @override
  List<Widget> get children => [nodeWidget, expandButton, ...subtrees];

  final NodeWidget nodeWidget;

  final Widget expandButton;

  final double expandButtonSize;

  final List<MindMap> subtrees;
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMindMap(
      expandButtonSize: expandButtonSize,
      showExpandButton: showExpandButton,
      theme: theme,
    );
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

  final double expandButtonSize;

  final bool showExpandButton;

  final MindMapTheme theme;

  RenderMindMap({
    required this.expandButtonSize,
    required this.showExpandButton,
    required this.theme,
  });

  @override
  void performLayout() {
    final rootNode = firstChild!;
    rootNode.layout(constraints, parentUsesSize: true);
    final rNParentData = rootNode.parentData as MindMapParentData;
    final rootNodeSize = rootNode.size;
    RenderBox expandButton = rNParentData.nextSibling!;
    expandButton.layout(constraints);
    RenderBox? subTree = childAfter(expandButton);
    double maxChildWidth = 0;
    double childrenHeight = 0;
    double subTreeYOffset = 0;
    final subTreeXOffset = rootNodeSize.width + theme.spacingWithSubTree;
    final leftWidth = subTree == null ? rootNodeSize.width : subTreeXOffset;
    while (subTree != null) {
      final parentData = subTree.parentData as MindMapParentData;
      subTree.layout(constraints, parentUsesSize: true);
      parentData.offset = Offset(subTreeXOffset, subTreeYOffset);
      subTreeYOffset += subTree.size.height + theme.spacingBetweenSubTree;
      if (subTree.size.width > maxChildWidth) {
        maxChildWidth = subTree.size.width;
      }
      childrenHeight += subTree.size.height;
      final nextSubTree = parentData.nextSibling;
      if (nextSubTree != null) childrenHeight += theme.spacingBetweenSubTree;
      subTree = nextSubTree;
    }
    final width = leftWidth + maxChildWidth;
    if (childrenHeight > rootNodeSize.height) {
      size = Size(width, childrenHeight);
      rNParentData.offset = Offset(
        0,
        (childrenHeight - rootNodeSize.height) / 2,
      );
    } else {
      size = Size(width, rootNodeSize.height);
      final moreTranslateY = (rootNodeSize.height - childrenHeight) / 2;
      subTree = rNParentData.nextSibling;
      while (subTree != null) {
        final parentData = subTree.parentData as MindMapParentData;
        parentData.offset += Offset(0, moreTranslateY);
        subTree = parentData.nextSibling;
      }
    }
    if (showExpandButton) {
      // TODO 2是按钮和节点的距离
      final offset = Offset(
        rootNodeSize.width + 2,
        (rootNodeSize.height - expandButtonSize) / 2,
      );
      (expandButton.parentData as MindMapParentData).offset =
          rNParentData.offset + offset;
      size = Size(size.width + 2 + expandButtonSize, size.height);
      assert(
        rootNodeSize.height > expandButtonSize,
        'expandButtonSize too big',
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final rootNode = firstChild!;
    final rNParentData = rootNode.parentData as MindMapParentData;
    final rootNodeOffset = rNParentData.offset + offset;
    context.paintChild(rootNode, rootNodeOffset);
    RenderBox expandButton = rNParentData.nextSibling!;
    RenderBox? subtree = childAfter(expandButton);
    final lienStartOffset =
        rootNodeOffset + Offset(rootNode.size.width, rootNode.size.height / 2);
    while (subtree != null) {
      final parentData = subtree.parentData as MindMapParentData;
      final subtreeOffset = parentData.offset + offset;
      context.paintChild(subtree, parentData.offset + offset);
      drawMindCurve(
        context.canvas,
        lienStartOffset,
        subtreeOffset + Offset(0, subtree.size.height / 2),
      );
      subtree = parentData.nextSibling;
    }
    if (showExpandButton) {
      drawMindCurve(
        context.canvas,
        lienStartOffset,
        lienStartOffset + Offset(2, 0),
      );
      context.paintChild(
        expandButton,
        (expandButton.parentData as MindMapParentData).offset + offset,
      );
    }
  }

  /// 从 [from] 到 [to] 画一条 XMind 风格的贝塞尔曲线
  /// [thickness] 线宽，[color] 颜色
  void drawMindCurve(
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

  // RenderFlex f;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class MindMapParentData extends ContainerBoxParentData<RenderBox> {
  @override
  String toString() => 'MindMap: ${super.toString()}';
}
