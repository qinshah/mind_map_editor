import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final BuildContext context;
  final Offset start;
  final List<Offset> ends;

  LinePainter({
    required this.context,
    required this.start,
    required this.ends,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.onSurface.withAlpha(100)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var end in ends) {
      final path = Path();
      path.moveTo(start.dx, start.dy);
      final controlPoint1 = Offset(start.dx + (end.dx - start.dx) * 0.5, start.dy);
      final controlPoint2 = Offset(start.dx + (end.dx - start.dx) * 0.5, end.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        end.dx,
        end.dy,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.ends.length != ends.length;
  }
}
