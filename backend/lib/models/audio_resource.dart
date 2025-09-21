class AudioResource {
  final String id;
  final String title;
  final String url;
  final String thumbnailUrl;
  final int duration;
  final bool isPremium;

  AudioResource({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    required this.duration,
    this.isPremium = false,
  });

  factory AudioResource.fromMap(Map<String, dynamic> map) {
    return AudioResource(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      thumbnailUrl: map['thumbnailUrl'],
      duration: map['duration'],
      isPremium: map['isPremium'] ?? false,
    );
  }
}
