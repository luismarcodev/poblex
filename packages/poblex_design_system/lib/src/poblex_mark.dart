import 'package:flutter/material.dart';

/// Decorative Poblex symbol. The accompanying visible name supplies semantics.
class PoblexMark extends StatelessWidget {
  const PoblexMark({super.key, this.size = 40, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _MarkPainter(color ?? Theme.of(context).colorScheme.primary),
      ),
    ),
  );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 112, size.height / 112);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(24, 96)
      ..lineTo(24, 45)
      ..cubicTo(24, 27, 38, 14, 56, 14)
      ..cubicTo(74, 14, 88, 27, 88, 45)
      ..cubicTo(88, 63, 74, 76, 56, 76)
      ..lineTo(40, 76);
    canvas.drawPath(path, paint);
    canvas.drawCircle(const Offset(56, 45), 7, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => oldDelegate.color != color;
}
