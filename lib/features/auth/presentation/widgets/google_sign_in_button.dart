import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import 'google_logo.dart';

/// A premium "Continue with Google" button with pressed, loading and
/// disabled (while signing in) states, plus a subtle scale animation.
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
    this.label = 'Continue with Google',
    this.loadingLabel = 'Signing in...',
  });

  final VoidCallback onTap;
  final bool isLoading;
  final String label;
  final String loadingLabel;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool loading = widget.isLoading;

    return Semantics(
      button: true,
      enabled: !loading,
      label: widget.label,
      child: AbsorbPointer(
        absorbing: loading,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: loading ? 0.85 : 1.0,
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutBack,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: loading
                          ? const SizedBox(
                              key: ValueKey<String>('spinner'),
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: AppColors.onLightSurface,
                              ),
                            )
                          : const GoogleLogo(
                              key: ValueKey<String>('logo'), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      loading ? widget.loadingLabel : widget.label,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: AppColors.onLightSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}