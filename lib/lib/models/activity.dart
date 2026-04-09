class Activity {
  final String id;
  final String name;
  final String category;
  final String budget;
  final bool isOutdoor;
  final double lat;
  final double lng;
  final String emoji;
  double score;

  Activity({
    required this.id,
    required this.name,
    required this.category,
    required this.budget,
    required this.isOutdoor,
    required this.lat,
    required this.lng,
    required this.emoji,
    this.score = 0,
  });
}