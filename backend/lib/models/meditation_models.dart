enum MeditationCategory {
  sleep,
  focus,
  anxiety,
  stress,
  mindfulness,
  beginner
}

extension MeditationCategoryExtension on MeditationCategory {
  String get displayName {
    switch (this) {
      case MeditationCategory.sleep:
        return 'Sueño';
      case MeditationCategory.focus:
        return 'Concentración';
      case MeditationCategory.anxiety:
        return 'Ansiedad';
      case MeditationCategory.stress:
        return 'Estrés';
      case MeditationCategory.mindfulness:
        return 'Mindfulness';
      case MeditationCategory.beginner:
        return 'Principiantes';
    }
  }
}

class MeditationSession {
  final String id;
  final String title;
  final String description;
  final int duration; // en segundos
  final MeditationCategory category;
  final String audioUrl;
  final String imageUrl;
  final bool isPremium;

  MeditationSession({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.audioUrl,
    required this.imageUrl,
    this.isPremium = false,
  });

  factory MeditationSession.fromMap(Map<String, dynamic> map) {
    return MeditationSession(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      duration: map['duration'],
      category: MeditationCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
        orElse: () => MeditationCategory.beginner,
      ),
      audioUrl: map['audioUrl'],
      imageUrl: map['imageUrl'],
      isPremium: map['isPremium'] ?? false,
    );
  }
}

class MeditationProgress {
  final String sessionId;
  final int completedTime;
  final int totalTime;
  final int lastPlayedPosition;

  MeditationProgress({
    required this.sessionId,
    required this.completedTime,
    required this.totalTime,
    required this.lastPlayedPosition,
  });
} 