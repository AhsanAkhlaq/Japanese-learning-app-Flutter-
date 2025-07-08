class Lesson {
  final String id;
  final String title;
  final String titleJapanese;
  final String description;
  final String category;
  final String difficulty;
  final int order;
  final List<LessonContent> content;
  final List<String> vocabulary;
  final List<String> grammar;
  final String audioUrl;
  final String imageUrl;
  final int estimatedTime;
  final List<String> prerequisites;
  final bool isLocked;
  final int points;

  Lesson({
    required this.id,
    required this.title,
    required this.titleJapanese,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.order,
    required this.content,
    required this.vocabulary,
    required this.grammar,
    this.audioUrl = '',
    this.imageUrl = '',
    required this.estimatedTime,
    required this.prerequisites,
    this.isLocked = false,
    required this.points,
  });

  factory Lesson.fromFirestore(String id, Map<String, dynamic> data) {
    return Lesson(
      id: id,
      title: data['title'] ?? '',
      titleJapanese: data['titleJapanese'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'beginner',
      order: data['order'] ?? 0,
      content: (data['content'] as List<dynamic>? ?? [])
          .map((item) => LessonContent.fromMap(item))
          .toList(),
      vocabulary: List<String>.from(data['vocabulary'] ?? []),
      grammar: List<String>.from(data['grammar'] ?? []),
      audioUrl: data['audioUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      estimatedTime: data['estimatedTime'] ?? 15,
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
      isLocked: data['isLocked'] ?? false,
      points: data['points'] ?? 10,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'titleJapanese': titleJapanese,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'order': order,
      'content': content.map((item) => item.toMap()).toList(),
      'vocabulary': vocabulary,
      'grammar': grammar,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'estimatedTime': estimatedTime,
      'prerequisites': prerequisites,
      'isLocked': isLocked,
      'points': points,
    };
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? titleJapanese,
    String? description,
    String? category,
    String? difficulty,
    int? order,
    List<LessonContent>? content,
    List<String>? vocabulary,
    List<String>? grammar,
    String? audioUrl,
    String? imageUrl,
    int? estimatedTime,
    List<String>? prerequisites,
    bool? isLocked,
    int? points,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      titleJapanese: titleJapanese ?? this.titleJapanese,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      order: order ?? this.order,
      content: content ?? this.content,
      vocabulary: vocabulary ?? this.vocabulary,
      grammar: grammar ?? this.grammar,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      prerequisites: prerequisites ?? this.prerequisites,
      isLocked: isLocked ?? this.isLocked,
      points: points ?? this.points,
    );
  }
}

class LessonContent {
  final String
  type; // 'text', 'audio', 'video', 'exercise', 'vocabulary', 'grammar'
  final String title;
  final String content;
  final String contentJapanese;
  final String romaji;
  final String explanation;
  final String audioUrl;
  final String imageUrl;
  final Map<String, dynamic> exerciseData;
  final int order;

  LessonContent({
    required this.type,
    required this.title,
    required this.content,
    this.contentJapanese = '',
    this.romaji = '',
    this.explanation = '',
    this.audioUrl = '',
    this.imageUrl = '',
    this.exerciseData = const {},
    required this.order,
  });

  factory LessonContent.fromMap(Map<String, dynamic> data) {
    return LessonContent(
      type: data['type'] ?? 'text',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      contentJapanese: data['contentJapanese'] ?? '',
      romaji: data['romaji'] ?? '',
      explanation: data['explanation'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      exerciseData: Map<String, dynamic>.from(data['exerciseData'] ?? {}),
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'contentJapanese': contentJapanese,
      'romaji': romaji,
      'explanation': explanation,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'exerciseData': exerciseData,
      'order': order,
    };
  }

  LessonContent copyWith({
    String? type,
    String? title,
    String? content,
    String? contentJapanese,
    String? romaji,
    String? explanation,
    String? audioUrl,
    String? imageUrl,
    Map<String, dynamic>? exerciseData,
    int? order,
  }) {
    return LessonContent(
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      contentJapanese: contentJapanese ?? this.contentJapanese,
      romaji: romaji ?? this.romaji,
      explanation: explanation ?? this.explanation,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      exerciseData: exerciseData ?? this.exerciseData,
      order: order ?? this.order,
    );
  }
} // TODO Implement this library.
