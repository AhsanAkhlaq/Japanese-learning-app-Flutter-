// TODO Implement this library.
class Flashcard {
  final String id;
  final String front;
  final String back;
  final String frontJapanese;
  final String backJapanese;
  final String romaji;
  final String category;
  final String difficulty;
  final List<String> tags;
  final String imageUrl;
  final String audioUrl;
  final String pronunciation;
  final List<String> examples;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    this.frontJapanese = '',
    this.backJapanese = '',
    this.romaji = '',
    required this.category,
    required this.difficulty,
    required this.tags,
    this.imageUrl = '',
    this.audioUrl = '',
    this.pronunciation = '',
    required this.examples,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Flashcard.fromFirestore(String id, Map<String, dynamic> data) {
    return Flashcard(
      id: id,
      front: data['front'] ?? '',
      back: data['back'] ?? '',
      frontJapanese: data['frontJapanese'] ?? '',
      backJapanese: data['backJapanese'] ?? '',
      romaji: data['romaji'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'beginner',
      tags: List<String>.from(data['tags'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      pronunciation: data['pronunciation'] ?? '',
      examples: List<String>.from(data['examples'] ?? []),
      notes: data['notes'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'front': front,
      'back': back,
      'frontJapanese': frontJapanese,
      'backJapanese': backJapanese,
      'romaji': romaji,
      'category': category,
      'difficulty': difficulty,
      'tags': tags,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'pronunciation': pronunciation,
      'examples': examples,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
    String? frontJapanese,
    String? backJapanese,
    String? romaji,
    String? category,
    String? difficulty,
    List<String>? tags,
    String? imageUrl,
    String? audioUrl,
    String? pronunciation,
    List<String>? examples,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
      frontJapanese: frontJapanese ?? this.frontJapanese,
      backJapanese: backJapanese ?? this.backJapanese,
      romaji: romaji ?? this.romaji,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      pronunciation: pronunciation ?? this.pronunciation,
      examples: examples ?? this.examples,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FlashcardSession {
  final String id;
  final String userId;
  final List<String> flashcardIds;
  final Map<String, FlashcardResult> results;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;
  final String sessionType; // 'study', 'review', 'quiz'
  final int totalCards;
  final int correctAnswers;
  final int wrongAnswers;
  final double accuracy;

  FlashcardSession({
    required this.id,
    required this.userId,
    required this.flashcardIds,
    required this.results,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    required this.sessionType,
    required this.totalCards,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.accuracy = 0.0,
  });

  factory FlashcardSession.fromFirestore(String id, Map<String, dynamic> data) {
    final resultsData = data['results'] as Map<String, dynamic>? ?? {};
    final results = resultsData.map(
      (key, value) => MapEntry(key, FlashcardResult.fromMap(value)),
    );

    return FlashcardSession(
      id: id,
      userId: data['userId'] ?? '',
      flashcardIds: List<String>.from(data['flashcardIds'] ?? []),
      results: results,
      startTime: data['startTime']?.toDate() ?? DateTime.now(),
      endTime: data['endTime']?.toDate(),
      isCompleted: data['isCompleted'] ?? false,
      sessionType: data['sessionType'] ?? 'study',
      totalCards: data['totalCards'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      wrongAnswers: data['wrongAnswers'] ?? 0,
      accuracy: data['accuracy']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    final resultsData = results.map(
      (key, value) => MapEntry(key, value.toMap()),
    );

    return {
      'userId': userId,
      'flashcardIds': flashcardIds,
      'results': resultsData,
      'startTime': startTime,
      'endTime': endTime,
      'isCompleted': isCompleted,
      'sessionType': sessionType,
      'totalCards': totalCards,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'accuracy': accuracy,
    };
  }

  FlashcardSession copyWith({
    String? id,
    String? userId,
    List<String>? flashcardIds,
    Map<String, FlashcardResult>? results,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    String? sessionType,
    int? totalCards,
    int? correctAnswers,
    int? wrongAnswers,
    double? accuracy,
  }) {
    return FlashcardSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      flashcardIds: flashcardIds ?? this.flashcardIds,
      results: results ?? this.results,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      sessionType: sessionType ?? this.sessionType,
      totalCards: totalCards ?? this.totalCards,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}

class FlashcardResult {
  final String flashcardId;
  final bool isCorrect;
  final DateTime answeredAt;
  final int timeTaken; // in seconds
  final String difficulty; // 'easy', 'medium', 'hard'
  final String confidence; // 'low', 'medium', 'high'

  FlashcardResult({
    required this.flashcardId,
    required this.isCorrect,
    required this.answeredAt,
    required this.timeTaken,
    required this.difficulty,
    required this.confidence,
  });

  factory FlashcardResult.fromMap(Map<String, dynamic> data) {
    return FlashcardResult(
      flashcardId: data['flashcardId'] ?? '',
      isCorrect: data['isCorrect'] ?? false,
      answeredAt: data['answeredAt']?.toDate() ?? DateTime.now(),
      timeTaken: data['timeTaken'] ?? 0,
      difficulty: data['difficulty'] ?? 'medium',
      confidence: data['confidence'] ?? 'medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flashcardId': flashcardId,
      'isCorrect': isCorrect,
      'answeredAt': answeredAt,
      'timeTaken': timeTaken,
      'difficulty': difficulty,
      'confidence': confidence,
    };
  }

  FlashcardResult copyWith({
    String? flashcardId,
    bool? isCorrect,
    DateTime? answeredAt,
    int? timeTaken,
    String? difficulty,
    String? confidence,
  }) {
    return FlashcardResult(
      flashcardId: flashcardId ?? this.flashcardId,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
      timeTaken: timeTaken ?? this.timeTaken,
      difficulty: difficulty ?? this.difficulty,
      confidence: confidence ?? this.confidence,
    );
  }
}

// Spaced Repetition Algorithm
class SpacedRepetitionCard {
  final String flashcardId;
  final int interval; // days until next review
  final double easeFactor; // difficulty multiplier
  final int repetitions; // number of successful reviews
  final DateTime nextReview;
  final int quality; // last response quality (0-5)

  SpacedRepetitionCard({
    required this.flashcardId,
    this.interval = 1,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    required this.nextReview,
    this.quality = 0,
  });

  factory SpacedRepetitionCard.fromMap(Map<String, dynamic> data) {
    return SpacedRepetitionCard(
      flashcardId: data['flashcardId'] ?? '',
      interval: data['interval'] ?? 1,
      easeFactor: data['easeFactor']?.toDouble() ?? 2.5,
      repetitions: data['repetitions'] ?? 0,
      nextReview: data['nextReview']?.toDate() ?? DateTime.now(),
      quality: data['quality'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flashcardId': flashcardId,
      'interval': interval,
      'easeFactor': easeFactor,
      'repetitions': repetitions,
      'nextReview': nextReview,
      'quality': quality,
    };
  }

  // Calculate next review based on SM-2 algorithm
  SpacedRepetitionCard calculateNextReview(int responseQuality) {
    if (responseQuality < 3) {
      // Failed - reset to beginning
      return SpacedRepetitionCard(
        flashcardId: flashcardId,
        interval: 1,
        easeFactor: easeFactor,
        repetitions: 0,
        nextReview: DateTime.now().add(Duration(days: 1)),
        quality: responseQuality,
      );
    }

    // Passed - calculate next interval
    int newInterval;
    if (repetitions == 0) {
      newInterval = 1;
    } else if (repetitions == 1) {
      newInterval = 6;
    } else {
      newInterval = (interval * easeFactor).round();
    }

    // Update ease factor
    final newEaseFactor =
        (easeFactor +
                (0.1 -
                    (5 - responseQuality) *
                        (0.08 + (5 - responseQuality) * 0.02)))
            .clamp(1.3, double.infinity);

    return SpacedRepetitionCard(
      flashcardId: flashcardId,
      interval: newInterval,
      easeFactor: newEaseFactor,
      repetitions: repetitions + 1,
      nextReview: DateTime.now().add(Duration(days: newInterval)),
      quality: responseQuality,
    );
  }
}
