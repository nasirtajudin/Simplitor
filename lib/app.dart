import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/simplitor_mark.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/coming_soon/presentation/pages/coming_soon_page.dart';
import 'features/onboarding/data/profile_repository.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/widgets/onboarding_form_widgets.dart';

class SimplitorApp extends StatelessWidget {
  const SimplitorApp({super.key, required this.firebaseSupported});

  final bool firebaseSupported;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simplitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: _AuthGate(firebaseSupported: firebaseSupported),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.firebaseSupported});

  final bool firebaseSupported;

  @override
  Widget build(BuildContext context) {
    if (!firebaseSupported) {
      return const LoginPage(signInSupported: false);
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthSplash();
        }

        final User? user = snapshot.data;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(opacity: animation, child: child),
          child: user == null
              ? const LoginPage(
                  key: ValueKey<String>('login'), signInSupported: true)
              : _ProfileGate(
                  key: ValueKey<String>('profile-${user.uid}'), user: user),
        );
      },
    );
  }
}

/// After sign-in, checks Firestore: existing profile → Coming Soon,
/// no profile → onboarding (new members only).
class _ProfileGate extends StatefulWidget {
  const _ProfileGate({required this.user});

  final User user;

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

enum _ProfileStatus { loading, exists, missing, error }

class _ProfileGateState extends State<_ProfileGate> {
  _ProfileStatus _status = _ProfileStatus.loading;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    setState(() => _status = _ProfileStatus.loading);
    try {
      final bool exists =
          await ProfileRepository.instance.hasProfile(widget.user.uid);
      if (!mounted) return;
      setState(() => _status =
          exists ? _ProfileStatus.exists : _ProfileStatus.missing);
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = _ProfileStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(opacity: animation, child: child),
      child: switch (_status) {
        _ProfileStatus.loading => const _AuthSplash(
            key: ValueKey<String>('loading')),
        _ProfileStatus.error => _ProfileError(
            key: const ValueKey<String>('error'), onRetry: _checkProfile),
        _ProfileStatus.exists => ComingSoonPage(
            key: const ValueKey<String>('home'), user: widget.user),
        _ProfileStatus.missing => OnboardingPage(
            key: const ValueKey<String>('onboarding'),
            user: widget.user,
            onCompleted: () =>
                setState(() => _status = _ProfileStatus.exists),
          ),
      },
    );
  }
}

class _AuthSplash extends StatelessWidget {
  const _AuthSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: SimplitorMark(size: 80, pulse: true)),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SimplitorMark(size: 72),
              const SizedBox(height: 24),
              const Text(
                "We couldn't reach Simplitor",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              PrimaryButton(label: 'Try again', onTap: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}