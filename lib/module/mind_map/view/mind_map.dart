import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mind_map_editor/data_model/mind_map_theme.dart';
import 'package:mind_map_editor/module/mind_map/mind_map_notifier.dart';
import 'package:mind_map_editor/data_model/xmind.dart';
import 'package:provider/provider.dart';

class MindMap extends StatelessWidget {
  const MindMap({
    super.key,
    required this.rootNodeBuilder,
    required this.rootNode,
    this.childNodeBuilder,
  });

  final Node rootNode;

  final Widget Function(Node node) rootNodeBuilder;

  final Widget Function(Node node)? childNodeBuilder;

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MindMapNotifier>();
    final depth = rootNode.path.length;
    final theme = depth == 1
        // 根节点
        ? MindMapTheme(spacingBetweenChild: 20, spacingWithChild: 40)
        : depth == 2
        // 根节点的子节点
        ? MindMapTheme(spacingBetweenChild: 10, spacingWithChild: 30)
        // 后续节点
        : MindMapTheme();
    final isExpanded = notifier.getExpanded(rootNode.id);
    return Container(
      color: Colors.primaries[rootNode.hashCode % Colors.primaries.length]
          .withAlpha(66),
      child: RenderMindMapWidget(
        key: Key('${rootNode.id}：isExpanded：$isExpanded'),
        rootNodeWidget: rootNodeBuilder(rootNode),
        subtrees: isExpanded
            ? List.generate(rootNode.childNodes.length, (index) {
                final nextRootNode = rootNode.childNodes[index];
                return MindMap(
                  rootNodeBuilder: childNodeBuilder ?? rootNodeBuilder,
                  rootNode: nextRootNode,
                );
              })
            : [],
      ),
    );
  }
}

class RenderMindMapWidget extends MultiChildRenderObjectWidget {
  const RenderMindMapWidget({
    required super.key,
    required this.rootNodeWidget,
    required this.subtrees,
  });

  @override
  List<Widget> get children => [rootNodeWidget, ...subtrees];

  final Widget rootNodeWidget;
  final List<MindMap> subtrees;
  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderMindMap();
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

  @override
  void performLayout() {
    final rootNode = firstChild!;
    rootNode.layout(constraints, parentUsesSize: true);
    final rNParentData = rootNode.parentData as MindMapParentData;
    final rootNodeSize = rootNode.size;
    RenderBox? subTree = rNParentData.nextSibling;
    double maxChildWidth = 0;
    double childrenHeight = 0;
    double childTreeTranslateY = 0;
    while (subTree != null) {
      final parentData = subTree.parentData as MindMapParentData;
      subTree.layout(constraints, parentUsesSize: true);
      parentData.offset = Offset(rootNodeSize.width, childTreeTranslateY);
      childTreeTranslateY += subTree.size.height;
      childrenHeight += subTree.size.height;
      if (subTree.size.width > maxChildWidth) {
        maxChildWidth = subTree.size.width;
      }
      subTree = parentData.nextSibling;
    }
    final width = rootNodeSize.width + maxChildWidth;
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
    context.paintChild(rootNode, rNParentData.offset + offset);
    RenderBox? subtree = childAfter(rootNode);
    while (subtree != null) {
      final parentData = subtree.parentData as MindMapParentData;
      context.paintChild(subtree, parentData.offset + offset);
      subtree = parentData.nextSibling;
    }
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
