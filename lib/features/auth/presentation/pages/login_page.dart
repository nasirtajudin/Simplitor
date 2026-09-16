import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/open_link.dart';
import '../../../../core/widgets/ambient_glow.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/simplitor_mark.dart';
import '../../data/auth_repository.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.signInSupported = true});

  final bool signInSupported;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  bool _isSigningIn = false;
  String? _error;

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isSigningIn) return;

    setState(() {
      _isSigningIn = true;
      _error = null;
    });

    try {
      final User? user = await AuthRepository.instance.signInWithGoogle();
      if (!mounted) return;
      if (user == null) {
        // The user closed the Google account picker — reset quietly.
        setState(() => _isSigningIn = false);
      }
      // On success the AuthGate in app.dart takes over.
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        _error = failure.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSigningIn = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  void _handleUnsupported() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google Sign-In is coming soon on this platform.'),
      ),
    );
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
                    const Spacer(flex: 4),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.0, 0.38),
                      dy: 10,
                      child: const Center(
                        child: SimplitorMark(size: 104, pulse: true),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.06, 0.44),
                      child: const Text(
                        'Simplitor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.12, 0.50),
                      child: const Text(
                        'Simplify. Organize. Achieve.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.accentSoft,
                        ),
                      ),
                    ),
                    const Spacer(flex: 5),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.20, 0.58),
                      dy: 12,
                      child: Column(
                        children: const <Widget>[
                          Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Let's get you in",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Access your workspace with your Google account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.28, 0.66),
                      dy: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          GoogleSignInButton(
                            isLoading: _isSigningIn,
                            onTap: widget.signInSupported
                                ? _handleGoogleSignIn
                                : _handleUnsupported,
                          ),
                          const SizedBox(height: 18),
                          _ErrorBox(message: _error),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      animation: _entrance,
                      interval: const Interval(0.38, 0.76),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          const Text(
                            'By continuing, you agree to our ',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                          _LinkText(
                            label: 'Terms of Service',
                            onTap: () => openExternalLink('https://google.com'),
                          ),
                          const Text(
                            ' & ',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                          _LinkText(
                            label: 'Privacy Policy',
                            onTap: () => openExternalLink('https://google.com'),
                          ),
                          const Text(
                            '.',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
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

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: message == null
          ? const SizedBox(width: double.infinity)
          : Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.error.withOpacity(0.35)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.error_outline_rounded,
                      size: 20, color: AppColors.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message!,
                      style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.accentSoft,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.accentSoft.withOpacity(0.4),
        ),
      ),
    );
  }
}