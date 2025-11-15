import 'package:flutter/widgets.dart';

class MyTCntlr extends TransformationController {
  Size? viewportSize;
  final double minScale;
  final double maxScale;

  MyTCntlr({this.minScale = 0.1, this.maxScale = 6})
    : assert(minScale > 0),
      assert(maxScale > minScale);

  /// 重置(恢复为单位矩阵)
  void reset() => value = Matrix4.identity();

  /// 平移
  void move(Offset offset) {
    value = value.clone()..translate(offset.dx, offset.dy);
  }

  /// 获取当前缩放倍数
  double getCurScale() => value.getMaxScaleOnAxis();

  /// 缩放至
  void zoomTo(double targetScale) {
    if (viewportSize == null) {
      throw Exception('请使用LayoutBuilder包裹组件并更新$runtimeType的viewportSize');
    }
    targetScale = targetScale.clamp(minScale, maxScale);
    // 1. 拿到 viewport 中心对应的逻辑坐标
    final Offset viewerCenter = Offset(
      viewportSize!.width / 2,
      viewportSize!.height / 2,
    );
    final Offset canvasCenter = toScene(viewerCenter); // 关键：映射到子树坐标系
    final double ratio = targetScale / getCurScale(); // 关键：只乘一次
    // 2. 以 canvasCenter 为中心做缩放
    value = value.clone()
      ..translate(canvasCenter.dx, canvasCenter.dy)
      ..scale(ratio)
      ..translate(-canvasCenter.dx, -canvasCenter.dy);
  }

  /// 按倍数缩放
  void zoomIn({double scale = 1.5}) => zoomTo(getCurScale() * scale);
}
