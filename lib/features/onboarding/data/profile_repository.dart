import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_profile.dart';

/// Saves and reads the user's profile document in Cloud Firestore.
/// Document path: users/{uid}
class ProfileRepository {
  ProfileRepository._();

  static final ProfileRepository instance = ProfileRepository._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// True when the signed-in user has already completed onboarding.
  Future<bool> hasProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _db.collection('users').doc(uid).get();
    return snapshot.exists;
  }

  /// Creates the profile document. Called once, at the end of onboarding.
  Future<void> saveProfile(String uid, UserProfile profile) async {
    final User? user = FirebaseAuth.instance.currentUser;

    await _db.collection('users').doc(uid).set(<String, dynamic>{
      ...profile.toMap(),
      'uid': uid,
      'email': user?.email ?? '',
      'photoUrl': user?.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}