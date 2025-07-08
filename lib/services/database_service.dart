import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lesson.dart';
import '../models/flashcard.dart';
import '../models/quiz.dart';
import '../models/user_progress.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? '';

  // Lessons Collection
  Future<List<Lesson>> getLessons({String? category}) async {
    try {
      Query query = _firestore.collection('lessons');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final QuerySnapshot snapshot = await query.orderBy('order').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Lesson.fromFirestore(doc.id, data);
      }).toList();
    } catch (e) {
      print('Get Lessons Error: $e');
      return [];
    }
  }

  // Get lesson by ID
  Future<Lesson?> getLesson(String lessonId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('lessons')
          .doc(lessonId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Lesson.fromFirestore(doc.id, data);
      }
      return null;
    } catch (e) {
      print('Get Lesson Error: $e');
      return null;
    }
  }

  // Flashcards Collection
  Future<List<Flashcard>> getFlashcards({
    String? category,
    String? difficulty,
  }) async {
    try {
      Query query = _firestore.collection('flashcards');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty);
      }

      final QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Flashcard.fromFirestore(doc.id, data);
      }).toList();
    } catch (e) {
      print('Get Flashcards Error: $e');
      return [];
    }
  }

  // Complete Lesson
  Future<void> completeLesson(String lessonId, int score) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('completed_lessons')
          .doc(lessonId)
          .set({
            'lessonId': lessonId,
            'score': score,
            'completedAt': FieldValue.serverTimestamp(),
          });

      // Update user's completed lessons array
      await _firestore.collection('users').doc(userId).update({
        'completedLessons': FieldValue.arrayUnion([lessonId]),
      });

      notifyListeners();
    } catch (e) {
      print('Complete Lesson Error: $e');
    }
  }

  // Save Quiz Result
  Future<void> saveQuizResult(
    String quizId,
    int score,
    int totalQuestions,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_results')
          .add({
            'quizId': quizId,
            'score': score,
            'totalQuestions': totalQuestions,
            'percentage': (score / totalQuestions) * 100,
            'completedAt': FieldValue.serverTimestamp(),
          });

      notifyListeners();
    } catch (e) {
      print('Save Quiz Result Error: $e');
    }
  }

  // Get Quiz Results
  Future<List<Map<String, dynamic>>> getQuizResults() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_results')
          .orderBy('completedAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Get Quiz Results Error: $e');
      return [];
    }
  }

  // Add to Favorites
  Future<void> addToFavorites(String itemId, String itemType) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('$itemType-$itemId')
          .set({
            'itemId': itemId,
            'itemType': itemType,
            'addedAt': FieldValue.serverTimestamp(),
          });

      notifyListeners();
    } catch (e) {
      print('Add to Favorites Error: $e');
    }
  }

  // Remove from Favorites
  Future<void> removeFromFavorites(String itemId, String itemType) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('$itemType-$itemId')
          .delete();

      notifyListeners();
    } catch (e) {
      print('Remove from Favorites Error: $e');
    }
  }

  // Get Favorites
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Get Favorites Error: $e');
      return [];
    }
  }

  // Update Study Streak
  Future<void> updateStudyStreak() async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final lastStudyDate = userData['lastStudyDate'] as Timestamp?;
        final currentStreak = userData['currentStreak'] ?? 0;
        final maxStreak = userData['maxStreak'] ?? 0;

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        int newStreak = 1;

        if (lastStudyDate != null) {
          final lastStudy = lastStudyDate.toDate();
          final lastStudyDay = DateTime(
            lastStudy.year,
            lastStudy.month,
            lastStudy.day,
          );
          final daysDifference = today.difference(lastStudyDay).inDays;

          if (daysDifference == 0) {
            // Same day, don't update streak
            return;
          } else if (daysDifference == 1) {
            // Consecutive day
            newStreak = currentStreak + 1;
          } else {
            // Streak broken
            newStreak = 1;
          }
        }

        await _firestore.collection('users').doc(userId).update({
          'currentStreak': newStreak,
          'maxStreak': newStreak > maxStreak ? newStreak : maxStreak,
          'lastStudyDate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Update Study Streak Error: $e');
    }
  }

  // Get Study Statistics
  Future<Map<String, dynamic>> getStudyStatistics() async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Get completed lessons count
        final completedLessonsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('completed_lessons')
            .get();

        // Get quiz results
        final quizResultsSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('quiz_results')
            .get();

        return {
          'totalPoints': userData['totalPoints'] ?? 0,
          'currentStreak': userData['currentStreak'] ?? 0,
          'maxStreak': userData['maxStreak'] ?? 0,
          'completedLessons': completedLessonsSnapshot.docs.length,
          'quizzesTaken': quizResultsSnapshot.docs.length,
          'level': userData['level'] ?? 'Beginner',
          'progress': userData['progress'] ?? {},
        };
      }

      return {};
    } catch (e) {
      print('Get Study Statistics Error: $e');
      return {};
    }
  }
} // TODO Implement this library.
