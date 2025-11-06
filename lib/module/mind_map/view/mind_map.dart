import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_notifier.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:mind_map_editor/module/mind_map/view/node_widget.dart';
import 'package:provider/provider.dart';

typedef NodeBuilder = NodeWidget Function(Node node, int depth, int indexInBrother);

typedef ThemeBuilder = MindMapTheme Function(int depth);

class MindMap extends StatelessWidget {
  const MindMap({
    super.key,
    required this.nodeBuilder,
    required this.rootNode,
    required this.depth,
    required this.indexInBrother,
    required this.themeBuilder,
  });

  const MindMap.root({
    required super.key,
    required this.nodeBuilder,
    required this.rootNode,
    required this.themeBuilder,
  }) : depth = 0,
       indexInBrother = 0;

  final Node rootNode;

  final int depth;
  final int indexInBrother;

  final NodeBuilder nodeBuilder;

  final ThemeBuilder themeBuilder;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MindMapNotifier>();
    final isExpanded = notifier.getExpanded(rootNode.id);
    return Container(
      // color: Colors.primaries[rootNode.hashCode % Colors.primaries.length]
      //     .withAlpha(66),
      child: RenderMindMapWidget(
        theme: themeBuilder(depth),
        key: Key('${rootNode.id}：isExpanded：$isExpanded'),
        rootNodeWidget: nodeBuilder(rootNode, depth, indexInBrother),
        subtrees: isExpanded
            ? List.generate(rootNode.childNodes.length, (index) {
                final nextRootNode = rootNode.childNodes[index];
                return MindMap(
                  themeBuilder: themeBuilder,
                  nodeBuilder: nodeBuilder,
                  rootNode: nextRootNode,
                  depth: depth + 1,
                  indexInBrother: index,
                );
              })
            : [],
      ),
    );
  }
}

class RenderMindMapWidget extends MultiChildRenderObjectWidget {
  const RenderMindMapWidget({
    required this.theme,
    required super.key,
    required this.rootNodeWidget,
    required this.subtrees,
  });

  final MindMapTheme theme;

  @override
  List<Widget> get children => [rootNodeWidget, ...subtrees];

  final Widget rootNodeWidget;

  final List<MindMap> subtrees;
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMindMap(theme: theme);
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

  final MindMapTheme theme;

  RenderMindMap({required this.theme});

  @override
  void performLayout() {
    final rootNode = firstChild!;
    rootNode.layout(constraints, parentUsesSize: true);
    final rNParentData = rootNode.parentData as MindMapParentData;
    final rootNodeSize = rootNode.size;
    RenderBox? subTree = rNParentData.nextSibling;
    double maxChildWidth = 0;
    double childrenHeight = 0;
    double subTreeYOffset = 0;
    final subTreeXOffset = rootNodeSize.width + theme.spacingWithSubTree;
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
    final width = subTreeXOffset + maxChildWidth;
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
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final rootNode = firstChild!;
    final rNParentData = rootNode.parentData as MindMapParentData;
    final rootNodeOffset = rNParentData.offset + offset;
    context.paintChild(rootNode, rootNodeOffset);
    RenderBox? subtree = rNParentData.nextSibling;
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
