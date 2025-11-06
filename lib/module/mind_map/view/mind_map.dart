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
      // color: Colors.primaries[rootNode.hashCode % Colors.primaries.length]
      //     .withAlpha(66),
      child: RenderMindMapWidget(
        key: Key('${rootNode.id}：isExpanded：$isExpanded'),
        rootNodeWidget: rootNodeBuilder(rootNode),
        subtree: isExpanded
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
    required this.subtree,
  });

  @override
  List<Widget> get children => [rootNodeWidget, ...subtree];

  final Widget rootNodeWidget;
  final List<MindMap> subtree;
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
    final rootNodeSize = rootNode.size;
    RenderBox? childTree = childAfter(rootNode);
    double maxChildWidth = 0;
    double childrenHeight = 0;
    double childTreeTranslateY = 0;
    for (; childTree != null; childTree = childAfter(childTree)) {
      childTree.layout(constraints, parentUsesSize: true);
      (childTree.parentData as MindMapParentData).offset = Offset(
        rootNodeSize.width,
        childTreeTranslateY,
      );
      childTreeTranslateY += childTree.size.height;
      childrenHeight += childTree.size.height;
      if (childTree.size.width > maxChildWidth) {
        maxChildWidth = childTree.size.width;
      }
    }
    final width = rootNodeSize.width + maxChildWidth;
    if (childrenHeight > rootNodeSize.height) {
      size = Size(width, childrenHeight);
      (rootNode.parentData as MindMapParentData).offset = Offset(
        0,
        (childrenHeight - rootNodeSize.height) / 2,
      );
    } else {
      size = Size(width, rootNodeSize.height);
      final moreTranslateY = (rootNodeSize.height - childrenHeight) / 2;
      childTree = childAfter(rootNode);
      for (; childTree != null; childTree = childAfter(childTree)) {
        (childTree.parentData as MindMapParentData).offset += Offset(
          0,
          moreTranslateY,
        );
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
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
