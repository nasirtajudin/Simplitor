import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:simplitor/core/theme/app_theme.dart';

/// The Simplitor logo: a glossy dark rounded tile with a glowing white "S".
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
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
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
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breath,
      builder: (BuildContext context, Widget? child) {
        final double t =
            widget.pulse ? Curves.easeInOut.transform(_breath.value) : 0.0;
        return Transform.scale(
          scale: 1.0 + 0.03 * t,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SimplitorMarkPainter(
              glowStrength: widget.glow ? 0.55 + 0.45 * t : 0.0,
            ),
          ),
        );
      },
    );
  }
}

class _SimplitorMarkPainter extends CustomPainter {
  _SimplitorMarkPainter({required this.glowStrength});

  final double glowStrength;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 100.0;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale, scale);

    // Soft halo behind the tile.
    if (glowStrength > 0) {
      final ui.Paint halo = Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          58,
          <Color>[
            AppColors.accent.withOpacity(0.20 * glowStrength),
            AppColors.accent.withOpacity(0),
          ],
        );
      canvas.drawRect(const Rect.fromLTWH(-58, -58, 116, 116), halo);
    }

    // Glossy dark tile.
    final RRect tile = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-32, -32, 64, 64),
      const Radius.circular(15),
    );

    canvas.drawRRect(
      tile,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, -32),
          const Offset(0, 32),
          <Color>[
            const Color(0xFF2E3A63),
            const Color(0xFF131A36),
            const Color(0xFF090D1E),
          ],
        ),
    );

    // Gloss highlight on the upper half.
    canvas.save();
    canvas.clipRRect(tile);
    canvas.drawRect(
      const Rect.fromLTWH(-32, -32, 64, 27),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(0, -32),
          const Offset(0, -5),
          <Color>[
            Colors.white.withOpacity(0.14),
            Colors.white.withOpacity(0),
          ],
        ),
    );
    canvas.restore();

    // Thin edge.
    canvas.drawRRect(
      tile,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Colors.white.withOpacity(0.10),
    );

    // The "S" — blue glow first, then the white stroke.
    final Path s = Path()
      ..moveTo(14, -17)
      ..cubicTo(14, -26, -14, -26, -14, -15)
      ..cubicTo(-14, -4, 14, -4, 14, 7)
      ..cubicTo(14, 19, -14, 19, -14, 27);

    canvas.drawPath(
      s,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.accent.withOpacity(0.28 + 0.28 * glowStrength)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4.5),
    );

    canvas.drawPath(
      s,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = ui.Gradient.linear(
          const Offset(0, -26),
          const Offset(0, 27),
          <Color>[const Color(0xFFFFFFFF), const Color(0xFFE9F0FB)],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _SimplitorMarkPainter oldDelegate) =>
      oldDelegate.glowStrength != glowStrength;
}