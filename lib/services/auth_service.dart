import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .attemptLightweightAuthentication();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.toString(),
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!);

      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Google Sign In Error: $e');
      return null;
    }
  }

  // Email/Password Sign Up
  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(displayName);
      await _createUserDocument(userCredential.user!);

      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Sign Up Error: $e');
      return null;
    }
  }

  // Email/Password Sign In
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      notifyListeners();
      return userCredential;
    } catch (e) {
      print('Sign In Error: $e');
      return null;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? 'Japanese Learner',
        'photoURL': user.photoURL,
        'level': 'Beginner',
        'totalPoints': 0,
        'streakDays': 0,
        'lastActiveDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'preferences': {
          'dailyGoal': 30, // minutes
          'notificationsEnabled': true,
          'studyReminders': true,
        },
        'progress': {
          'hiragana': 0,
          'katakana': 0,
          'kanji': 0,
          'vocabulary': 0,
          'grammar': 0,
        },
        'achievements': [],
        'completedLessons': [],
        'favorites': [],
      });
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Reset Password Error: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);

        // Update Firestore document
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
          'photoURL': photoURL,
        });

        notifyListeners();
      }
    } catch (e) {
      print('Update Profile Error: $e');
    }
  }

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData() async {
    final user = currentUser;
    if (user != null) {
      return await _firestore.collection('users').doc(user.uid).get();
    }
    throw Exception('No user signed in');
  }

  // Update user progress
  Future<void> updateUserProgress(String subject, int progress) async {
    try {
      final user = currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'progress.$subject': progress,
          'lastActiveDate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Update Progress Error: $e');
    }
  }

  // Add points to user
  Future<void> addPoints(int points) async {
    try {
      final user = currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'totalPoints': FieldValue.increment(points),
          'lastActiveDate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Add Points Error: $e');
    }
  }

  // Update streak
  Future<void> updateStreak() async {
    try {
      final user = currentUser;
      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        final userData = userDoc.data() as Map<String, dynamic>;

        final lastActiveDate = userData['lastActiveDate'] as Timestamp?;
        final currentDate = DateTime.now();

        int streakDays = userData['streakDays'] ?? 0;

        if (lastActiveDate != null) {
          final lastActive = lastActiveDate.toDate();
          final daysDifference = currentDate.difference(lastActive).inDays;

          if (daysDifference == 1) {
            streakDays += 1;
          } else if (daysDifference > 1) {
            streakDays = 1;
          }
        } else {
          streakDays = 1;
        }

        await _firestore.collection('users').doc(user.uid).update({
          'streakDays': streakDays,
          'lastActiveDate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Update Streak Error: $e');
    }
  }
}
