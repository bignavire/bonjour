import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  List<String> categories;
  String budget;

  UserPreferences({required this.categories, required this.budget});

  static Future<UserPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final cats = prefs.getStringList('pref_categories') ?? ['sport'];
    final budget = prefs.getString('pref_budget') ?? 'gratuit';
    return UserPreferences(categories: cats, budget: budget);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pref_categories', categories);
    await prefs.setString('pref_budget', budget);
  }
}