class RecommendationException implements Exception {
  final String message;

  const RecommendationException(this.message);

  @override
  String toString() => 'RecommendationException: $message';
}
