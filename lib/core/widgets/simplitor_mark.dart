import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:simplitor/core/theme/app_theme.dart';

/// The Simplitor brand mark: a metallic "S" inside a translucent rounded
/// square frame, wrapped in a tilted orbital ring carrying four satellites —
/// three glassy, one solid.
///
/// The satellites orbit continuously; [pulse] adds a gentle breathing
/// animation to the glow and scale.
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
    with TickerProviderStateMixin {
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      _breath.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _orbit.dispose();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_orbit, _breath]),
      builder: (BuildContext context, Widget? child) {
        final double breath =
            widget.pulse ? Curves.easeInOut.transform(_breath.value) : 0.0;
        return Transform.scale(
          scale: 1.0 + 0.025 * breath,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SimplitorMarkPainter(
              orbit: _orbit.value,
              glowStrength: widget.glow ? 0.55 + 0.45 * breath : 0.0,
            ),
          ),
        );
      },
    );
  }
}

class _SimplitorMarkPainter extends CustomPainter {
  _SimplitorMarkPainter({required this.orbit, required this.glowStrength});

  final double orbit;
  final double glowStrength;

  static const double _tilt = -0.38;
  static const double _ringRx = 44.0;
  static const double _ringRy = 15.0;

  static Offset _ringPoint(double t) {
    final double x = _ringRx * math.cos(t);
    final double y = _ringRy * math.sin(t);
    return Offset(
      x * math.cos(_tilt) - y * math.sin(_tilt),
      x * math.sin(_tilt) + y * math.cos(_tilt),
    );
  }

  static Path _ringArc(double start, double end) {
    final Path path = Path();
    for (int i = 0; i <= 56; i++) {
      final double t = start + (end - start) * i / 56;
      final Offset p = _ringPoint(t);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path;
  }

  void _drawSatellite(Canvas canvas, Offset p, int index, bool front) {
    if (index == 0) {
      // The one solid satellite — bright, with a halo of its own.
      if (front) {
        canvas.drawCircle(
          p,
          7.5,
          Paint()..color = AppColors.accent.withOpacity(0.30),
        );
      }
      canvas.drawCircle(p, 4.2, Paint()..color = AppColors.accentSoft);
    } else {
      canvas.drawCircle(
        p,
        front ? 3.1 : 2.5,
        Paint()..color = Colors.white.withOpacity(front ? 0.55 : 0.22),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 100.0;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale, scale);

    // Ambient glow behind everything.
    if (glowStrength > 0) {
      final ui.Paint glow = Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          55,
          <Color>[
            AppColors.accent.withOpacity(0.28 * glowStrength),
            AppColors.accent.withOpacity(0),
          ],
        );
      canvas.drawRect(const Rect.fromLTWH(-55, -55, 110, 110), glow);
    }

    // Back half of the orbital ring, plus satellites behind the frame.
    canvas.drawPath(
      _ringArc(math.pi, 2 * math.pi),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withOpacity(0.15),
    );
    for (int i = 0; i < 4; i++) {
      final double t = orbit * 2 * math.pi + i * math.pi / 2;
      if (math.sin(t) <= 0) {
        _drawSatellite(canvas, _ringPoint(t), i, false);
      }
    }

    // Translucent rounded-square frame.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, -30, 60, 60),
        const Radius.circular(11),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3
        ..color = Colors.white.withOpacity(0.30),
    );

    // The "S": soft blue halo first, then the metallic stroke.
    final Path s = Path()
      ..moveTo(10.5, -13.9)
      ..cubicTo(10.5, -20.6, -10.5, -20.6, -10.5, -12.4)
      ..cubicTo(-10.5, -4.1, 10.5, -4.1, 10.5, 4.1)
      ..cubicTo(10.5, 13.1, -10.5, 13.1, -10.5, 20.6);

    canvas.drawPath(
      s,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.accent.withOpacity(0.20 + 0.25 * glowStrength)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4.5),
    );

    canvas.drawPath(
      s,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(
          const Offset(0, -21),
          const Offset(0, 21),
          <Color>[AppColors.accentSoft, AppColors.silver, AppColors.accent],
        ),
    );

    // Front half of the ring and the satellites that pass in front.
    canvas.drawPath(
      _ringArc(0, math.pi),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = Colors.white.withOpacity(0.42),
    );
    for (int i = 0; i < 4; i++) {
      final double t = orbit * 2 * math.pi + i * math.pi / 2;
      if (math.sin(t) > 0) {
        _drawSatellite(canvas, _ringPoint(t), i, true);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SimplitorMarkPainter oldDelegate) =>
      oldDelegate.orbit != orbit || oldDelegate.glowStrength != glowStrength;
}