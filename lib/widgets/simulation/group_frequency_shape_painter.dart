import 'package:flutter/material.dart';
import 'dart:math' as math;

class GroupFrequencyShapePainter extends CustomPainter {
  final int count;
  final Color color;
  final double strokeWidth;

  const GroupFrequencyShapePainter({
    required this.count,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final inset = strokeWidth / 2 + 2;
    final rect = Rect.fromLTRB(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
    );

    if (rect.width <= 0 || rect.height <= 0) return;

    // 0 grille : contour circulaire.
    if (count <= 0) {
      canvas.drawOval(rect, paint);
      return;
    }

    final path = Path();

    // 1 grille : uniquement le trait supérieur.
    if (count == 1) {
      path.moveTo(rect.left, rect.top);
      path.lineTo(rect.right, rect.top);
      canvas.drawPath(path, paint);
      return;
    }

    // 2 grilles : trait supérieur et trait gauche.
    if (count == 2) {
      path.moveTo(rect.left, rect.top);
      path.lineTo(rect.right, rect.top);

      path.moveTo(rect.left, rect.top);
      path.lineTo(rect.left, rect.bottom);

      canvas.drawPath(path, paint);
      return;
    }

    // 3 grilles : triangle équilatéral.
    // 4 grilles : carré.
    // Au-delà : polygone régulier avec count côtés.
    final sides = count;
    final center = rect.center;
    final radius = math.min(rect.width, rect.height) / 2;

    // Une rotation de 45° donne au carré des côtés horizontaux
    // et verticaux. Le triangle commence par un sommet en haut.
    final startAngle = sides == 4 ? -math.pi / 4 : -math.pi / 2;

    for (var i = 0; i < sides; i++) {
      final angle = startAngle + 2 * math.pi * i / sides;

      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GroupFrequencyShapePainter oldDelegate) {
    return oldDelegate.count != count ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}