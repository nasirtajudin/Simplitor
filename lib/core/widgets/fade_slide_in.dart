import 'package:flutter/widgets.dart';

/// Fades a child in and slides it up as [animation] runs from 0 to 1.
///
/// If [interval] is provided it is applied first, which makes staggered
/// page entrances easy to build.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    required this.animation,
    this.interval,
    this.offset = const Offset(0, 18),
  });

  final Widget child;
  final Animation<double> animation;
  final Interval? interval;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? built) {
        final double raw =
            interval?.transform(animation.value) ?? animation.value;
        final double t = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(offset.dx * (1 - t), offset.dy * (1 - t)),
            child: built,
          ),
        );
      },
      child: child,
    );
  }
}