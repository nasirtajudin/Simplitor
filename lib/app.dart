import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/simplitor_mark.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/coming_soon/presentation/pages/coming_soon_page.dart';

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

/// Listens to Firebase auth state and swaps between the login page and the
/// Coming Soon page with a smooth fade transition.
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

        final bool signedIn = snapshot.data != null;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(opacity: animation, child: child),
          child: signedIn
              ? ComingSoonPage(
                  key: const ValueKey<String>('home'),
                  user: snapshot.data,
                )
              : const LoginPage(
                  key: ValueKey<String>('login'),
                  signInSupported: true,
                ),
        );
      },
    );
  }
}

class _AuthSplash extends StatelessWidget {
  const _AuthSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: SimplitorMark(size: 76, pulse: true)),
    );
  }
}