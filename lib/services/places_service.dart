import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  static Future<List<Map<String, dynamic>>> getPlacesAround({
    required double lat,
    required double lng,
    double radiusKm = 3,
  }) async {
    final radius = (radiusKm * 1000).toInt();

    final query = '''
[out:json][timeout:25];
(
  node["leisure"="pitch"](around:$radius,$lat,$lng);
  node["sport"="basketball"](around:$radius,$lat,$lng);
  node["sport"="soccer"](around:$radius,$lat,$lng);
  node["amenity"="cafe"](around:$radius,$lat,$lng);
  node["amenity"="restaurant"](around:$radius,$lat,$lng);
  node["amenity"="cinema"](around:$radius,$lat,$lng);
  node["leisure"="playground"](around:$radius,$lat,$lng);
  node["leisure"="park"](around:$radius,$lat,$lng);
);
out body;
''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter');
    final response = await http.post(url, body: {'data': query});

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final elements = data['elements'] as List;

    List<Map<String, dynamic>> places = [];

    for (final el in elements) {
      final tags = el['tags'] ?? {};
      final name = tags['name'] ?? tags['name:fr'] ?? '';
      if (name.isEmpty) continue;

      final elLat = el['lat'] as double;
      final elLng = el['lon'] as double;

      final distanceM = _distance(lat, lng, elLat, elLng);
      final distanceKm = distanceM / 1000;

      String emoji = '📍';
      String category = 'fun';

      if (tags['sport'] == 'basketball') { emoji = '🏀'; category = 'sport'; }
      else if (tags['sport'] == 'soccer' || tags['leisure'] == 'pitch') { emoji = '⚽'; category = 'sport'; }
      else if (tags['amenity'] == 'cafe') { emoji = '☕'; category = 'chill'; }
      else if (tags['amenity'] == 'restaurant') { emoji = '🍽️'; category = 'food'; }
      else if (tags['amenity'] == 'cinema') { emoji = '🎬'; category = 'culture'; }
      else if (tags['leisure'] == 'park') { emoji = '🌳'; category = 'chill'; }
      else if (tags['leisure'] == 'playground') { emoji = '🎮'; category = 'fun'; }

      places.add({
        'name': name,
        'emoji': emoji,
        'category': category,
        'lat': elLat,
        'lng': elLng,
        'distance': distanceKm,
        'distanceLabel': distanceKm < 1
            ? '${distanceM.toInt()} m'
            : '${distanceKm.toStringAsFixed(1)} km',
        'budget': 'gratuit',
        'isOutdoor': tags['leisure'] == 'pitch' ||
            tags['leisure'] == 'park' ||
            tags['sport'] != null,
      });
    }

    places.sort((a, b) =>
        (a['distance'] as double).compareTo(b['distance'] as double));

    return places.take(10).toList();
  }

  static double _distance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_rad(lat1)) * _cos(_rad(lat2)) *
        _sin(dLon / 2) * _sin(dLon / 2);
    return r * 2 * _atan2(a);
  }

  static double _rad(double deg) => deg * 3.141592653589793 / 180;
  static double _sin(double x) => x - x * x * x / 6;
  static double _cos(double x) => 1 - x * x / 2;
  static double _atan2(double x) => x < 1 ? x * (1 + x * (0.3 - 0.1 * x)) : 1.5;
}