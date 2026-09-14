import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';

/// A friendly, user-facing authentication failure.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Google Sign-In works on Android, iOS, macOS and the web.
  bool get isSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signOut() async {
    if (!isSupported) return;
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {
        // Best-effort: signing out of the Google account is optional.
      }
    }
    await _auth.signOut();
  }

  /// Signs in with Google.
  ///
  /// Returns the signed-in [User], or `null` when the user closed the
  /// account picker without choosing an account (not an error).
  Future<User?> signInWithGoogle() async {
    if (!isSupported) {
      throw const AuthFailure(
          'Google Sign-In is not available on this platform yet.');
    }

    try {
      if (kIsWeb) {
        final UserCredential result =
            await _auth.signInWithPopup(GoogleAuthProvider());
        return result.user;
      }

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; // User cancelled the account picker.
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
          return null; // User cancelled — not an error.
        case 'network-request-failed':
          throw const AuthFailure(
              'Unable to sign in. Please check your internet connection and try again.');
        case 'too-many-requests':
          throw const AuthFailure(
              'Too many attempts. Please wait a moment and try again.');
        default:
          throw const AuthFailure('Sign-in failed. Please try again in a moment.');
      }
    } on Exception catch (e) {
      // Failures from the google_sign_in plugin (PlatformException / ApiException).
      final String text = e.toString();
      if (text.contains('ApiException: 10') ||
          text.contains('ApiException: 12500') ||
          text.contains('DEVELOPER_ERROR')) {
        throw const AuthFailure(
            'Google Sign-In is not configured for this build yet. '
            'Please check the SHA-1 fingerprint in the Firebase Console.');
      }
      throw const AuthFailure(
          'Unable to sign in. Please check your internet connection and try again.');
    } catch (_) {
      throw const AuthFailure('Something went wrong. Please try again.');
    }
  }
}