import 'package:hive/hive.dart';
import 'package:gotime/lib/models/activity.dart'; // ✅ corrigé

class LocalStorageService {
  static const String boxName = 'activitiesBox';

  Future<void> saveActivities(List<Activity> activities) async {
    var box = await Hive.openBox(boxName);

    List<Map<String, dynamic>> data = activities.map((a) => {
          'id': a.id,
          'name': a.name, // ✅ corrigé
          'category': a.category,
          'budget': a.budget,
          'lat': a.lat,
          'lng': a.lng,
          'isOutdoor': a.isOutdoor,
          'emoji': a.emoji, // ✅ ajouté
        }).toList();

    await box.put('activities', data);

    print("💾 SAUVEGARDE LOCAL OK");
  }

  Future<List<Activity>> getActivities() async {
    var box = await Hive.openBox(boxName);

    final rawData = box.get('activities');

    if (rawData == null) return [];

    final list = List<Map<String, dynamic>>.from(rawData);

    final activities = list.map((item) {
      return Activity(
        id: item['id'] ?? '',
        name: item['name'] ?? '', // ✅ corrigé
        category: item['category'] ?? '',
        budget: item['budget'] ?? 'free',
        lat: (item['lat'] ?? 0).toDouble(),
        lng: (item['lng'] ?? 0).toDouble(),
        isOutdoor: item['isOutdoor'] ?? false,
        emoji: item['emoji'] ?? '🎯', // ✅ ajouté
      );
    }).toList();

    print("📦 DONNÉES LOCALES CHARGÉES: ${activities.length}");

    return activities;
  }
}