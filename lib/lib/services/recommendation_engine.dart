import 'package:geolocator/geolocator.dart';
import 'package:gotime/lib/models/activity.dart';
import 'package:gotime/lib/models/user_preferences.dart';

class RecommendationEngine {
  static double _score({
    required Activity activity,
    required UserPreferences prefs,
    required String weather,
    required double distanceKm,
    required List<String> history,
  }) {
    double s = 0;

    if (prefs.categories.contains(activity.category)) {
      s += 40;
    }
    if (prefs.budget == activity.budget) {
      s += 20;
    } else if (activity.budget == 'gratuit') {
      s += 10;
    }

    if (weather == 'sunny' && activity.isOutdoor) {
      s += 25;
    } else if (weather == 'rainy' && !activity.isOutdoor) {
      s += 25;
    } else {
      s += 10;
    }

    if (distanceKm < 2) {
      s += 20;
    } else if (distanceKm < 5) {
      s += 12;
    } else if (distanceKm < 10) {
      s += 5;
    }

    if (!history.contains(activity.id)) {
      s += 15;
    } else {
      s -= 10;
    }

    return s.clamp(0, 100);
  }

  static Future<List<Activity>> recommend({
    required List<Activity> activities,
    required UserPreferences prefs,
    required String weather,
    required Position position,
    required List<String> history,
    int limit = 3,
  }) async {
    for (var a in activities) {
      final dist = Geolocator.distanceBetween(
            position.latitude, position.longitude, a.lat, a.lng) /
          1000;
      a.score = _score(
        activity: a,
        prefs: prefs,
        weather: weather,
        distanceKm: dist,
        history: history,
      );
    }
    activities.sort((a, b) => b.score.compareTo(a.score));
    return activities.take(limit).toList();
  }
}