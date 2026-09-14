import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ambient_glow.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/simplitor_mark.dart';
import '../../../auth/data/auth_repository.dart';

class ComingSoonPage extends StatefulWidget {
  const ComingSoonPage({super.key, required this.user});

  final User? user;

  @override
  State<ComingSoonPage> createState() => _ComingSoonPageState();
}

class _ComingSoonPageState extends State<ComingSoonPage>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  bool _isSigningOut = false;

  String get _firstName {
    final String? name = widget.user?.displayName;
    if (name == null || name.trim().isEmpty) return 'there';
    return name.trim().split(RegExp(r'\s+')).first;
  }

  String? get _email => widget.user?.email;
  String? get _photoUrl => widget.user?.photoURL;

  @override
  void dispose() {
    _entrance.dispose();
    _dots.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    try {
      await AuthRepository.instance.signOut();
    } catch (_) {
      if (mounted) setState(() => _isSigningOut = false);
    }
    // On success the AuthGate animates back to the login page.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: AmbientGlow()),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 22),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.0, 0.4),
                      child: _Header(
                        firstName: _firstName,
                        email: _email,
                        photoUrl: _photoUrl,
                      ),
                    ),
                    const Spacer(flex: 3),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.06, 0.5),
                      dy: 14,
                      child: const Center(
                        child: SimplitorMark(size: 168, pulse: true),
                      ),
                    ),
                    const SizedBox(height: 34),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.16, 0.56),
                      child: const _ComingSoonBadge(),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.24, 0.64),
                      child: const Text(
                        'Something great is\nalmost here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          height: 1.25,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.32, 0.72),
                      child: const Text(
                        'We are putting the finishing touches on Simplitor. '
                        'Your organized life is just around the corner.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.40, 0.80),
                      child: _PulsingDots(controller: _dots),
                    ),
                    const Spacer(flex: 4),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.48, 0.88),
                      child: _SignOutButton(
                        onTap: _signOut,
                        busy: _isSigningOut,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.firstName, this.email, this.photoUrl});

  final String firstName;
  final String? email;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _Avatar(photoUrl: photoUrl, name: firstName),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome back, $firstName!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (email != null)
                Text(
                  email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.name});

  final String? photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final Widget fallback = Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
    Widget content = fallback;
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      content = ClipOval(
        child: Image.network(
          photoUrl!,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      );
    }
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.accent, AppColors.accentDeep],
        ),
      ),
      child: content,
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.accent.withOpacity(0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSoft,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.accentSoft.withOpacity(0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'COMING SOON',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
                color: AppColors.accentSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDots extends StatelessWidget {
  const _PulsingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (int i) {
            final double wave =
                (math.sin(2 * math.pi * (controller.value + i / 3)) + 1) / 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentSoft.withOpacity(0.25 + 0.75 * wave),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap, required this.busy});

  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: busy ? null : onTap,
        icon: busy
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout_rounded, size: 17),
        label: const Text('Sign out'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        ),
      ),
    );
  }
}