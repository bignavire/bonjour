import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gotime/lib/models/activity.dart'; // ✅ CORRIGÉ
import 'local_storage_service.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _local = LocalStorageService();

  Future<List<Activity>> getActivities() async {
    try {
      // 🔥 ONLINE
      final snapshot = await _firestore.collection('activities').get();

      final activities = snapshot.docs.map((doc) {
        final data = doc.data();

        return Activity(
          id: doc.id,
          name: data['name'] ?? '',
          category: data['category'] ?? '',
          budget: data['budget'] ?? 'free',
          isOutdoor: data['isOutdoor'] ?? true,
          lat: (data['lat'] ?? 0).toDouble(),
          lng: (data['lng'] ?? 0).toDouble(),
          emoji: data['emoji'] ?? '🎯',
        );
      }).toList();

      // 💾 SAUVEGARDE OFFLINE
      await _local.saveActivities(activities);

      print("🔥 ONLINE DATA: ${activities.length} activités");

      return activities;

    } catch (e) {
      // 📵 OFFLINE
      print("📵 MODE OFFLINE ACTIVÉ");

      final localData = await _local.getActivities();

      print("💾 DONNÉES LOCALES: ${localData.length}");

      return localData;
    }
  }
}