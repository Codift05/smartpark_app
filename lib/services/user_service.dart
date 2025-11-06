import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  /// Ensure a basic user profile document exists in Firestore.
  static Future<void> ensureUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final users = FirebaseFirestore.instance.collection('users');
    final ref = users.doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'email': user.email,
        'name': user.displayName ?? user.email ?? 'User',
        'avatar_url': null,
        'balance': 0,
        'notif_pref': true,
        'created_at': FieldValue.serverTimestamp(),
      });
    }
  }
}