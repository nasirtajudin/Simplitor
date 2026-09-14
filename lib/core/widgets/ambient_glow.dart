import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Soft radial light pools behind page content — pure decoration.
class AmbientGlow extends StatelessWidget {
  const AmbientGlow({super.key, this.topColor, this.rightColor});

  final Color? topColor;
  final Color? rightColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AmbientGlowPainter(
        topColor: topColor ?? AppColors.accent,
        rightColor: rightColor ?? const Color(0xFF7B6BD9),
      ),
      size: Size.infinite,
    );
  }
}

class _AmbientGlowPainter extends CustomPainter {
  _AmbientGlowPainter({required this.topColor, required this.rightColor});

  final Color topColor;
  final Color rightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final ui.Paint topLeft = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.18, size.height * 0.10),
        size.width * 0.75,
        <Color>[topColor.withOpacity(0.16), topColor.withOpacity(0)],
      );
    canvas.drawRect(rect, topLeft);

    final ui.Paint right = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.92, size.height * 0.38),
        size.width * 0.55,
        <Color>[rightColor.withOpacity(0.12), rightColor.withOpacity(0)],
      );
    canvas.drawRect(rect, right);
  }

  @override
  bool shouldRepaint(covariant _AmbientGlowPainter oldDelegate) =>
      oldDelegate.topColor != topColor || oldDelegate.rightColor != rightColor;
}