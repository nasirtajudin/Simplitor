import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The Simplitor "S" logo with a soft glow behind it.
/// Set [pulse] to true for a gentle breathing animation.
class SimplitorMark extends StatefulWidget {
  const SimplitorMark({
    super.key,
    this.size = 72.0,
    this.glow = true,
    this.pulse = false,
  });

  final double size;
  final bool glow;
  final bool pulse;

  @override
  State<SimplitorMark> createState() => _SimplitorMarkState();
}

class _SimplitorMarkState extends State<SimplitorMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double t = widget.pulse ? _controller.value : 0.0;
        return Transform.scale(
          scale: 1.0 + 0.04 * t,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SimplitorMarkPainter(
              glowStrength: widget.glow ? 0.55 + 0.35 * t : 0.0,
            ),
          ),
        );
      },
      child: const SizedBox(),
    );
  }
}

class _SimplitorMarkPainter extends CustomPainter {
  _SimplitorMarkPainter({required this.glowStrength});

  final double glowStrength;

  @override
  void paint(Canvas canvas, Size size) {
    final ui.Rect rect = Offset.zero & size;
    final double scale = size.width / 100.0;
    final Offset center = Offset(size.width / 2, size.height / 2);

    if (glowStrength > 0) {
      final ui.Paint glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          size.width * 0.62,
          <Color>[
            AppColors.accent.withOpacity(0.38 * glowStrength),
            AppColors.accent.withOpacity(0),
          ],
        );
      canvas.drawCircle(center, size.width * 0.62, glowPaint);
    }

    final Path path = Path()
      ..moveTo(64, 28)
      ..cubicTo(64, 19, 36, 19, 36, 30)
      ..cubicTo(36, 41, 64, 41, 64, 52)
      ..cubicTo(64, 64, 36, 64, 36, 74);

    final ui.Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = ui.Gradient.linear(
        rect.topCenter,
        rect.bottomCenter,
        <Color>[AppColors.accentSoft, AppColors.accent, Color(0xFFF17FC5)],
      );

    canvas.save();
    canvas.scale(scale, scale);
    canvas.drawPath(path, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SimplitorMarkPainter oldDelegate) =>
      oldDelegate.glowStrength != glowStrength;
}