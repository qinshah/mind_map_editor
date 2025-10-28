import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 渲染完成后把 size 抛给回调
class SizeChangeNotifier extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onSizeChange;

  const SizeChangeNotifier({
    required this.onSizeChange,
    super.key,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSizeReportingBox(onSizeChange);
  }
}

class _RenderSizeReportingBox extends RenderProxyBox {
  final ValueChanged<Size> onSizeChange;
  Size? _lastSize;

  _RenderSizeReportingBox(this.onSizeChange);

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (size == _lastSize) return;
    _lastSize = size;
    onSizeChange(size); // ← 抛给外部
  }
}
