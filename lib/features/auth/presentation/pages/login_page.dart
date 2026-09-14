import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
    duration: const Duration(milliseconds: 1200),
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
      // On success the AuthGate in app.dart swaps to the Coming Soon page.
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF151031), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(flex: 5),
                 FadeSlideIn(
                  animation: _entrance,
                  interval: const Interval(0.10, 0.55),
                  child: const Text(
                    'Simplitor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  animation: _entrance,
                  interval: const Interval(0.20, 0.62),
                  dy: 14,
                  child: const Text(
                    'Organize your life,\nsimplify your day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      letterSpacing: 0.1,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(flex: 6),
                FadeSlideIn(
                  animation: _entrance,
                  interval: const Interval(0.32, 0.72),
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
                const SizedBox(height: 22),
                FadeSlideIn(
                  animation: _entrance,
                  interval: const Interval(0.45, 0.85),
                  child: const Text(
                    'By continuing, you agree to our Terms of Service\nand acknowledge our Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated inline error box — appears with a size transition,
/// never shows raw exception text.
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
                border: Border.all(color: AppColors.error.withOpacity(0.35)),
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